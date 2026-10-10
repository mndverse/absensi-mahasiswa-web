import { pageTitle } from 'ember-page-title';
import { LinkTo } from '@ember/routing';

<template>
  {{pageTitle "Sistem Absensi Mahasiswa"}}

  <div class="app-container">
    <header class="app-header">
      <div class="brand">
        <div>
          <h1>Absensi Mahasiswa</h1>
          <p>Sistem Informasi Akademik</p>
        </div>
      </div>

      <nav class="navigation">
        <LinkTo @route="index" class="nav-link">
          Beranda
        </LinkTo>

        <LinkTo @route="mahasiswa" class="nav-link">
          Data Mahasiswa
        </LinkTo>

        <LinkTo @route="tentang" class="nav-link">
          Tentang
        </LinkTo>
      </nav>
    </header>

    <main class="main-content">
      {{outlet}}
    </main>

    <footer class="app-footer">
      <p>© 2026 Sistem Absensi Mahasiswa</p>
      <p>Dibuat menggunakan Ember.js</p>
    </footer>
  </div>
</template>