import { LinkTo } from '@ember/routing';

<template>
  <section class="home-page">
    <div class="home-content">
      <div class="home-decoration">
        <span class="home-icon">✓</span>
      </div>

      <p class="home-label">
        SISTEM INFORMASI AKADEMIK
      </p>

      <h1>
        Sistem Daftar Hadir
        <span>Mahasiswa</span>
      </h1>

      <div class="home-divider"></div>

      <p class="home-description">
        Selamat datang di sistem pencatatan kehadiran mahasiswa. Aplikasi ini
        dirancang untuk membantu proses pencatatan, pengelolaan, dan pemantauan
        kehadiran mahasiswa secara praktis, efektif, dan terstruktur.
      </p>

      <LinkTo @route="mahasiswa" class="primary-button home-button">
        <span>Mulai Catat Kehadiran</span>
        <span class="button-arrow">→</span>
      </LinkTo>

      <p class="home-note">
        <span class="note-dot"></span>
        Pencatatan kehadiran mahasiswa dalam satu aplikasi.
      </p>
    </div>

    <div class="home-side-decoration">
      <div class="decoration-line"></div>
      <span>AKADEMIK</span>
      <div class="decoration-line"></div>
    </div>
  </section>
</template>
