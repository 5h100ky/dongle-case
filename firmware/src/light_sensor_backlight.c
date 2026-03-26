/*
 * light_sensor_backlight.c
 *
 * Auto-brightness module for the Snake Dongle.
 * Reads an LDR (light-dependent resistor) via the Zephyr ADC API and adjusts
 * the ZMK backlight brightness accordingly.
 *
 * Build-time knobs (set in dongle.conf)
 * ──────────────────────────────────────
 *   CONFIG_SNAKE_LIGHT_SENSOR_BACKLIGHT      enable this module
 *   CONFIG_SNAKE_LIGHT_SENSOR_POLL_MS        sampling interval (ms)
 *   CONFIG_SNAKE_LIGHT_SENSOR_DIM_THRESHOLD  ADC value → dim backlight
 *   CONFIG_SNAKE_LIGHT_SENSOR_BRIGHT_THRESHOLD ADC value → full brightness
 */

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/adc.h>
#include <zephyr/logging/log.h>
#include <zmk/backlight.h>

LOG_MODULE_REGISTER(light_sensor_backlight, LOG_LEVEL_INF);

/* ── Devicetree bindings ─────────────────────────────────────────────── */
#define LIGHT_SENSOR_NODE DT_NODELABEL(light_sensor)

#if !DT_NODE_HAS_STATUS(LIGHT_SENSOR_NODE, okay)
#error "light_sensor node is not enabled in the devicetree overlay"
#endif

static const struct adc_dt_spec adc_channel =
    ADC_DT_SPEC_GET_BY_IDX(LIGHT_SENSOR_NODE, 0);

/* ── Configuration ───────────────────────────────────────────────────── */
#define POLL_MS         CONFIG_SNAKE_LIGHT_SENSOR_POLL_MS
#define DIM_THRESHOLD   CONFIG_SNAKE_LIGHT_SENSOR_DIM_THRESHOLD
#define BRIGHT_THRESHOLD CONFIG_SNAKE_LIGHT_SENSOR_BRIGHT_THRESHOLD

#define BRT_MIN  DT_PROP(LIGHT_SENSOR_NODE, min_brightness)
#define BRT_MAX  DT_PROP(LIGHT_SENSOR_NODE, max_brightness)

/* ── ADC sample buffer ───────────────────────────────────────────────── */
static int16_t adc_raw;
static struct adc_sequence sequence = {
    .buffer      = &adc_raw,
    .buffer_size = sizeof(adc_raw),
};

/* ── Map an ADC reading to a backlight brightness percentage (0–100) ── */
static uint8_t adc_to_brightness(int32_t raw)
{
    if (raw <= DIM_THRESHOLD)
        return BRT_MIN;
    if (raw >= BRIGHT_THRESHOLD)
        return BRT_MAX;

    /* Linear interpolation between dim and bright thresholds */
    int32_t range  = BRIGHT_THRESHOLD - DIM_THRESHOLD;
    int32_t offset = raw - DIM_THRESHOLD;
    return (uint8_t)(BRT_MIN + (offset * (BRT_MAX - BRT_MIN)) / range);
}

/* ── Worker thread ───────────────────────────────────────────────────── */
static void light_sensor_work_handler(struct k_work *work);
static K_WORK_DELAYABLE_DEFINE(light_sensor_work, light_sensor_work_handler);

static void light_sensor_work_handler(struct k_work *work)
{
    int err;

    err = adc_read(adc_channel.dev, &sequence);
    if (err < 0) {
        LOG_WRN("ADC read failed: %d", err);
    } else {
        int32_t val_mv = adc_raw;
        /* Convert raw counts to millivolts (optional, for logging) */
        adc_raw_to_millivolts_dt(&adc_channel, &val_mv);
        LOG_DBG("LDR raw=%d  val=%d mV", (int)adc_raw, (int)val_mv);

        uint8_t brightness = adc_to_brightness(adc_raw);
        zmk_backlight_set_brt(brightness);
    }

    k_work_reschedule(&light_sensor_work, K_MSEC(POLL_MS));
}

/* ── Module initialisation ───────────────────────────────────────────── */
static int light_sensor_init(void)
{
    int err;

    if (!adc_is_ready_dt(&adc_channel)) {
        LOG_ERR("ADC device %s is not ready", adc_channel.dev->name);
        return -ENODEV;
    }

    err = adc_channel_setup_dt(&adc_channel);
    if (err < 0) {
        LOG_ERR("ADC channel setup failed: %d", err);
        return err;
    }

    err = adc_sequence_init_dt(&adc_channel, &sequence);
    if (err < 0) {
        LOG_ERR("ADC sequence init failed: %d", err);
        return err;
    }

    LOG_INF("Light-sensor backlight module ready (poll=%d ms)", POLL_MS);
    k_work_schedule(&light_sensor_work, K_MSEC(POLL_MS));
    return 0;
}

SYS_INIT(light_sensor_init, APPLICATION, CONFIG_APPLICATION_INIT_PRIORITY);
