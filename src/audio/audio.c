#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio/miniaudio.h"

#include "audio.h"
#include <stdio.h>
#include <stdlib.h>

static ma_engine  g_engine;
static int        g_initialized = 0;

int audio_init(void) {
    if (g_initialized) return 1;

    ma_engine_config cfg = ma_engine_config_init();
    ma_result result = ma_engine_init(&cfg, &g_engine);
    if (result != MA_SUCCESS) {
        fprintf(stderr, "[Audio] Failed to initialize engine: %d\n", result);
        return 0;
    }

    g_initialized = 1;
    return 1;
}

void audio_shutdown(void) {
    if (!g_initialized) return;
    ma_engine_uninit(&g_engine);
    g_initialized = 0;
}

Sound* audio_load(const char* filepath) {
    if (!g_initialized) {
        if (!audio_init()) return NULL;
    }

    Sound* sound = (Sound*)calloc(1, sizeof(Sound));
    if (!sound) return NULL;

    sound->handle = (ma_sound*)calloc(1, sizeof(ma_sound));
    if (!sound->handle) {
        free(sound);
        return NULL;
    }

    ma_result result = ma_sound_init_from_file(
        &g_engine, filepath, 0, NULL, NULL, sound->handle
    );
    if (result != MA_SUCCESS) {
        fprintf(stderr, "[Audio] Failed to load '%s': %d\n", filepath, result);
        free(sound->handle);
        free(sound);
        return NULL;
    }

    sound->volume  = 1.0f;
    sound->pitch   = 1.0f;
    sound->looping = 0;
    sound->playing = 0;

    return sound;
}

void audio_destroy(Sound* sound) {
    if (!sound) return;
    if (sound->handle) {
        ma_sound_uninit(sound->handle);
        free(sound->handle);
        sound->handle = NULL;
    }
    free(sound);
}

int audio_play(Sound* sound) {
    if (!sound || !sound->handle) return 0;
    // Rewind to start before playing
    ma_sound_seek_to_pcm_frame(sound->handle, 0);
    ma_result r = ma_sound_start(sound->handle);
    if (r == MA_SUCCESS) {
        sound->playing = 1;
        return 1;
    }
    return 0;
}

int audio_stop(Sound* sound) {
    if (!sound || !sound->handle) return 0;
    ma_sound_stop(sound->handle);
    ma_sound_seek_to_pcm_frame(sound->handle, 0);
    sound->playing = 0;
    return 1;
}

int audio_pause(Sound* sound) {
    if (!sound || !sound->handle) return 0;
    ma_sound_stop(sound->handle);
    sound->playing = 0;
    return 1;
}

int audio_resume(Sound* sound) {
    if (!sound || !sound->handle) return 0;
    ma_result r = ma_sound_start(sound->handle);
    if (r == MA_SUCCESS) {
        sound->playing = 1;
        return 1;
    }
    return 0;
}

int audio_is_playing(Sound* sound) {
    if (!sound || !sound->handle) return 0;
    return ma_sound_is_playing(sound->handle);
}

int audio_is_looping(Sound* sound) {
    if (!sound || !sound->handle) return 0;
    return ma_sound_is_looping(sound->handle);
}

void audio_set_looping(Sound* sound, int loop) {
    if (!sound || !sound->handle) return;
    ma_sound_set_looping(sound->handle, loop);
    sound->looping = loop;
}

float audio_get_volume(Sound* sound) {
    if (!sound || !sound->handle) return 0.0f;
    return ma_sound_get_volume(sound->handle);
}

void audio_set_volume(Sound* sound, float volume) {
    if (!sound || !sound->handle) return;
    if (volume < 0.0f) volume = 0.0f;
    ma_sound_set_volume(sound->handle, volume);
    sound->volume = volume;
}

float audio_get_pitch(Sound* sound) {
    if (!sound || !sound->handle) return 1.0f;
    return ma_sound_get_pitch(sound->handle);
}

void audio_set_pitch(Sound* sound, float pitch) {
    if (!sound || !sound->handle) return;
    if (pitch < 0.1f) pitch = 0.1f;
    ma_sound_set_pitch(sound->handle, pitch);
    sound->pitch = pitch;
}

float audio_get_master_volume(void) {
    if (!g_initialized) return 0.0f;
    return ma_engine_get_volume(&g_engine);
}

void audio_set_master_volume(float volume) {
    if (!g_initialized) {
        if (!audio_init()) return;
    }
    if (volume < 0.0f) volume = 0.0f;
    ma_engine_set_volume(&g_engine, volume);
}
