import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';

const daftarSemester = [
  '1', '2', '3', '4', '5', '6', '7', '8',
];

const daftarStatus = [
  'Hadir', 'Izin', 'Sakit', 'Alpa',
];

function nomorUrut(index) {
  return index + 1;
}

function hitungStatus(daftar, status) {
  return daftar.filter(
    (item) => item.statusKehadiran === status,
  ).length;
}

function waktuWIB() {
  const sekarang = new Date();

  const tanggal = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Asia/Jakarta',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(sekarang);

  const jam = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Asia/Jakarta',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(sekarang);

  return {
    tanggal,
    jam,
  };
}

class DataMahasiswa {
  @tracked daftar = [];
  @tracked nama = '';
  @tracked kelas = '';
  @tracked nim = '';
  @tracked tanggalAbsen = '';
  @tracked jamAbsen = '';
  @tracked statusKehadiran = '';
  @tracked semester = '';
  @tracked sedangEdit = null;
  @tracked pencarian = '';

  constructor() {
    try {
      const tersimpan = JSON.parse(
        localStorage.getItem('daftarMahasiswa') || '[]',
      );

      this.daftar = tersimpan.map((item, index) => ({
        ...item,
        id: item.id ?? Date.now() + index,
      }));
    } catch {
      this.daftar = [];
    }

    this.perbaruiWaktu();
  }

  // Menghasilkan daftar mahasiswa sesuai kata pencarian.
  get daftarTersaring() {
    const kataKunci = this.pencarian.trim().toLowerCase();

    if (!kataKunci) {
      return this.daftar;
    }

    return this.daftar.filter((item) => {
      const nama = (item.nama || '').toLowerCase();
      const nim = (item.nim || '').toLowerCase();

      return (
        nama.includes(kataKunci) ||
        nim.includes(kataKunci)
      );
    });
  }

  perbaruiWaktu = () => {
    if (this.sedangEdit !== null) {
      return;
    }

    const waktu = waktuWIB();

    this.tanggalAbsen = waktu.tanggal;
    this.jamAbsen = waktu.jam;
  };

  mulaiPembaruanJam = () => {
    this.berhentiPembaruanJam();
    this.perbaruiWaktu();

    this.timer = setInterval(() => {
      this.perbaruiWaktu();
    }, 1000);
  };

  berhentiPembaruanJam = () => {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  };

  simpanPenyimpanan() {
    localStorage.setItem(
      'daftarMahasiswa',
      JSON.stringify(this.daftar),
    );
  }

  ubahInput = (field, event) => {
    this[field] = event.target.value;
  };

  tambahData = (event) => {
    event.preventDefault();

    const nama = this.nama.trim();
    const kelas = this.kelas.trim();
    const nim = this.nim.trim();
    const tanggalAbsen = this.tanggalAbsen.trim();
    const jamAbsen = this.jamAbsen;
    const statusKehadiran = this.statusKehadiran;
    const semester = this.semester;

    const formatTanggal =
      /^(0[1-9]|[12]\d|3[01])\/(0[1-9]|1[0-2])\/\d{4}$/;

    if (
      !nama ||
      !kelas ||
      !nim ||
      !tanggalAbsen ||
      !jamAbsen ||
      !statusKehadiran ||
      !semester
    ) {
      alert('Semua data harus diisi.');
      return;
    }

    if (!formatTanggal.test(tanggalAbsen)) {
      alert(
        'Format tanggal harus DD/MM/YYYY, contohnya 10/10/2026.',
      );
      return;
    }

    const [hari, bulan, tahun] = tanggalAbsen
      .split('/')
      .map(Number);

    const tanggalValid = new Date(
      tahun,
      bulan - 1,
      hari,
    );

    if (
      tanggalValid.getFullYear() !== tahun ||
      tanggalValid.getMonth() !== bulan - 1 ||
      tanggalValid.getDate() !== hari
    ) {
      alert('Tanggal yang dimasukkan tidak valid.');
      return;
    }

    const duplikat = this.daftar.some(
      (item) =>
        (item.nim || '').toLowerCase() === nim.toLowerCase() &&
        item.id !== this.sedangEdit,
    );

    if (duplikat) {
      alert('NIM sudah terdaftar dalam daftar absensi.');
      return;
    }

    const dataBaru = {
      nama,
      kelas,
      nim,
      tanggalAbsen,
      jamAbsen,
      statusKehadiran,
      semester,
    };

    if (this.sedangEdit !== null) {
      this.daftar = this.daftar.map((item) =>
        item.id === this.sedangEdit
          ? { ...item, ...dataBaru }
          : item,
      );
    } else {
      this.daftar = [
        ...this.daftar,
        {
          id: Date.now(),
          ...dataBaru,
        },
      ];
    }

    this.simpanPenyimpanan();
    this.resetForm();
  };

  editData = (item) => {
    this.berhentiPembaruanJam();

    this.nama = item.nama;
    this.kelas = item.kelas;
    this.nim = item.nim;
    this.tanggalAbsen = item.tanggalAbsen;
    this.jamAbsen = item.jamAbsen;
    this.statusKehadiran = item.statusKehadiran;
    this.semester = item.semester;
    this.sedangEdit = item.id;

    window.scrollTo({
      top: 0,
      behavior: 'smooth',
    });
  };

  hapusData = (id) => {
    if (!confirm('Apakah kamu yakin ingin menghapus data ini?')) {
      return;
    }

    this.daftar = this.daftar.filter(
      (item) => item.id !== id,
    );

    this.simpanPenyimpanan();
  };

  resetForm = () => {
    this.nama = '';
    this.kelas = '';
    this.nim = '';
    this.statusKehadiran = '';
    this.semester = '';
    this.sedangEdit = null;

    this.perbaruiWaktu();
    this.mulaiPembaruanJam();
  };

  timer = null;
}

const data = new DataMahasiswa();

data.mulaiPembaruanJam();

<template>
  <section>
    {{! Judul halaman }}
    <div class="page-heading">
      <h2>Daftar Hadir Mahasiswa</h2>
      <p>
        Tambahkan dan kelola data kehadiran mahasiswa melalui formulir berikut.
      </p>
    </div>

    {{! Statistik kehadiran }}
    <div class="statistik-container">
      <div class="statistik-card statistik-hadir">
        <div class="statistik-icon">✓</div>
        <div class="statistik-info">
          <p>Hadir</p>
          <h3>{{hitungStatus data.daftar "Hadir"}}</h3>
          <span>Data kehadiran</span>
        </div>
      </div>

      <div class="statistik-card statistik-izin">
        <div class="statistik-icon">✉</div>
        <div class="statistik-info">
          <p>Izin</p>
          <h3>{{hitungStatus data.daftar "Izin"}}</h3>
          <span>Data izin</span>
        </div>
      </div>

      <div class="statistik-card statistik-sakit">
        <div class="statistik-icon">✚</div>
        <div class="statistik-info">
          <p>Sakit</p>
          <h3>{{hitungStatus data.daftar "Sakit"}}</h3>
          <span>Data sakit</span>
        </div>
      </div>

      <div class="statistik-card statistik-alpa">
        <div class="statistik-icon">!</div>
        <div class="statistik-info">
          <p>Alpa</p>
          <h3>{{hitungStatus data.daftar "Alpa"}}</h3>
          <span>Tanpa keterangan</span>
        </div>
      </div>
    </div>

    {{! Formulir absensi }}
    <div class="form-card">
      <h2>
        {{if data.sedangEdit "Edit Data Kehadiran" "Formulir Absensi Mahasiswa"}}
      </h2>

      <form {{on "submit" data.tambahData}}>
        <div class="form-group">
          <label for="nama">Nama Mahasiswa</label>
          <input
            id="nama"
            type="text"
            value={{data.nama}}
            placeholder="Masukkan nama mahasiswa"
            required
            {{on "input" (fn data.ubahInput "nama")}}
          />
        </div>

        <div class="form-group">
          <label for="kelas">Kelas</label>
          <input
            id="kelas"
            type="text"
            value={{data.kelas}}
            placeholder="Masukkan kelas"
            required
            {{on "input" (fn data.ubahInput "kelas")}}
          />
        </div>

        <div class="form-group">
          <label for="nim">NIM</label>
          <input
            id="nim"
            type="text"
            value={{data.nim}}
            placeholder="Masukkan NIM"
            required
            {{on "input" (fn data.ubahInput "nim")}}
          />
        </div>

        <div class="form-group">
          <label for="tanggalAbsen">Tanggal Absen</label>
          <input
            id="tanggalAbsen"
            type="text"
            value={{data.tanggalAbsen}}
            placeholder="DD/MM/YYYY"
            pattern="(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}"
            title="Masukkan tanggal dengan format DD/MM/YYYY"
            required
            {{on "input" (fn data.ubahInput "tanggalAbsen")}}
          />
        </div>

        <div class="form-group">
          <label for="jamAbsen">Jam Absen (WIB)</label>
          <input
            id="jamAbsen"
            type="time"
            value={{data.jamAbsen}}
            required
            {{on "input" (fn data.ubahInput "jamAbsen")}}
          />
        </div>

        <div class="form-group">
          <label for="statusKehadiran">Status Kehadiran</label>
          <select
            id="statusKehadiran"
            value={{data.statusKehadiran}}
            required
            {{on "change" (fn data.ubahInput "statusKehadiran")}}
          >
            <option value="">Pilih status kehadiran</option>

            {{#each daftarStatus as |status|}}
              <option value={{status}}>{{status}}</option>
            {{/each}}
          </select>
        </div>

        <div class="form-group">
          <label for="semester">Semester</label>
          <select
            id="semester"
            value={{data.semester}}
            required
            {{on "change" (fn data.ubahInput "semester")}}
          >
            <option value="">Pilih semester</option>

            {{#each daftarSemester as |s|}}
              <option value={{s}}>Semester {{s}}</option>
            {{/each}}
          </select>
        </div>

        <button type="submit" class="primary-button">
          {{if data.sedangEdit "Simpan Perubahan" "Tambah Kehadiran"}}
        </button>

        {{#if data.sedangEdit}}
          <button
            type="button"
            class="secondary-button"
            {{on "click" data.resetForm}}
          >
            Batal
          </button>
        {{/if}}
      </form>
    </div>

    {{! Tabel data mahasiswa }}
    <div class="table-card">
      <h2>Daftar Hadir Mahasiswa</h2>

      {{! Kolom pencarian }}
      <div class="pencarian-container">
        <label for="pencarianMahasiswa">
          Cari Mahasiswa
        </label>

        <input
          id="pencarianMahasiswa"
          type="search"
          value={{data.pencarian}}
          placeholder="Masukkan nama atau NIM mahasiswa..."
          {{on "input" (fn data.ubahInput "pencarian")}}
        />
      </div>

      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>No.</th>
              <th>Nama</th>
              <th>Kelas</th>
              <th>NIM</th>
              <th>Tanggal Absen</th>
              <th>Jam Absen</th>
              <th>Status Kehadiran</th>
              <th>Semester</th>
              <th>Aksi</th>
            </tr>
          </thead>

          <tbody>
            {{#each data.daftarTersaring as |m index|}}
              <tr>
                <td>{{nomorUrut index}}</td>
                <td>{{m.nama}}</td>
                <td>{{m.kelas}}</td>
                <td>{{m.nim}}</td>
                <td>{{m.tanggalAbsen}}</td>
                <td>{{m.jamAbsen}}</td>
                <td>
                  <span
                    class="status-badge
                      {{if (eq m.statusKehadiran 'Hadir') 'status-hadir'}}
                      {{if (eq m.statusKehadiran 'Izin') 'status-izin'}}
                      {{if (eq m.statusKehadiran 'Sakit') 'status-sakit'}}
                      {{if (eq m.statusKehadiran 'Alpa') 'status-alpa'}}"
                  >
                    {{m.statusKehadiran}}
                  </span>
                </td>
                <td>{{m.semester}}</td>
                <td>
                  <button
                    type="button"
                    class="secondary-button"
                    {{on "click" (fn data.editData m)}}
                  >
                    Edit
                  </button>

                  <button
                    type="button"
                    class="danger-button"
                    {{on "click" (fn data.hapusData m.id)}}
                  >
                    Hapus
                  </button>
                </td>
              </tr>
            {{else}}
              <tr>
                <td colspan="9">
                  {{#if data.pencarian}}
                    Data mahasiswa tidak ditemukan.
                  {{else}}
                    Belum ada data kehadiran mahasiswa.
                  {{/if}}
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      </div>
    </div>
  </section>
</template>