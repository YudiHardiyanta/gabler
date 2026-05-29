# GABLER

**GABLER** adalah singkatan dari **General App Backend Local Environment Runner**.

GABLER adalah template environment lokal berbasis Docker untuk menjalankan project backend PHP dengan Nginx, MySQL, dan phpMyAdmin. Project web dapat dibuat sendiri di folder `www`.

## Isi Stack

- Nginx: web server di `http://localhost:8080`
- PHP-FPM: menjalankan file PHP
- MySQL: database di port `3306`
- phpMyAdmin: database manager di `http://localhost:8081`

## Struktur Folder

```text
c:\etc
+-- docker-compose.yml
+-- README.md
+-- mysql-data\
+-- nginx\
|   +-- default.conf
+-- php\
|   +-- Dockerfile
+-- www\
    +-- index.php
```

Keterangan:

- `www/index.php` adalah halaman utama.
- `www` adalah tempat menyimpan project PHP.
- `mysql-data` menyimpan data MySQL lokal.
- `nginx/default.conf` adalah konfigurasi Nginx.
- `php/Dockerfile` adalah image PHP custom dengan ekstensi MySQL.

## Install Docker

1. Download Docker Desktop:
   `https://www.docker.com/products/docker-desktop/`
2. Install Docker Desktop.
3. Aktifkan WSL 2 jika diminta.
4. Restart komputer jika diminta.
5. Buka Docker Desktop dan tunggu sampai running.
6. Cek instalasi:

```powershell
docker --version
docker compose version
```

## Cara Paling Mudah

Setelah Docker terinstall dan berjalan, di Windows jalankan file:

```text
start-gabler.bat
```

File ini akan menjalankan:

```powershell
docker compose up -d --build
```

Setelah selesai, buka:

- Halaman utama: `http://localhost:8080`
- phpMyAdmin: `http://localhost:8081`

## Menjalankan Stack

Masuk ke folder project:

```powershell
cd c:\etc
```

Jalankan semua service:

```powershell
docker compose up -d --build
```

Cek status container:

```powershell
docker compose ps
```

## URL Akses

- Halaman utama: `http://localhost:8080`
- phpMyAdmin: `http://localhost:8081`

## Database MySQL

Credential MySQL:

```text
Host dari container PHP: mysql
Host dari komputer lokal: localhost
Port: 3306
Database: appdb
User: appuser
Password: apppass
Root user: root
Root password: rootpass
```

Login phpMyAdmin:

```text
URL: http://localhost:8081
Username: root
Password: rootpass
```

Atau:

```text
Username: appuser
Password: apppass
```

## Command Harian

Menyalakan service:

```powershell
docker compose up -d
```

Menyalakan service sekaligus rebuild image:

```powershell
docker compose up -d --build
```

Melihat status container:

```powershell
docker compose ps
```

Melihat log:

```powershell
docker compose logs
docker compose logs -f
```

Restart service:

```powershell
docker compose restart
docker compose restart nginx
docker compose restart php
docker compose restart mysql
docker compose restart phpmyadmin
```

Masuk ke container PHP:

```powershell
docker compose exec php sh
```

Masuk ke MySQL:

```powershell
docker compose exec mysql mysql -uroot -prootpass
```

Mematikan container tanpa menghapus data:

```powershell
docker compose down
```

## Menambah Project PHP

Buat folder atau file baru di `www`.

Contoh project PHP biasa:

```text
www\project-baru\index.php
```

Akses:

```text
http://localhost:8080/project-baru/
```

Contoh isi `www\project-baru\index.php`:

```php
<?php
echo 'Project PHP berjalan';
```

## Menambah Project Laravel Sendiri

Laravel tidak disertakan sebagai project bawaan agar repository tetap ringan dan pengguna bebas membuat project sendiri.

Contoh membuat Laravel baru di folder `www`:

```powershell
cd c:\etc
docker run --rm -v "C:\etc\www:/app" composer create-project laravel/laravel nama-project
```

Akses Laravel:

```text
http://localhost:8080/nama-project/public/
```

Edit file `.env` Laravel agar memakai MySQL Docker:

```env
APP_URL=http://localhost:8080/nama-project/public

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=appdb
DB_USERNAME=appuser
DB_PASSWORD=apppass
```

Jalankan setup Laravel:

```powershell
docker compose exec php sh -lc "cd /var/www/html/nama-project && php artisan key:generate"
docker compose exec php sh -lc "cd /var/www/html/nama-project && php artisan migrate"
docker compose exec php sh -lc "cd /var/www/html/nama-project && chmod -R 777 storage bootstrap/cache && php artisan optimize:clear"
```

## Troubleshooting

Jika web tidak bisa dibuka:

```powershell
docker compose ps
docker compose logs nginx
docker compose logs php
```

Jika phpMyAdmin menampilkan error koneksi:

```text
phpMyAdmin tried to connect to the MySQL server, and the server rejected the connection.
```

Cek status MySQL:

```powershell
docker compose ps
docker compose logs mysql
```

Pastikan MySQL berstatus `healthy`.

Jika folder `mysql-data` sudah pernah dibuat dengan password lama, environment di `docker-compose.yml` tidak akan mengubah password database yang sudah ada. Untuk reset database lokal dari awal:

```powershell
docker compose down
Remove-Item -Recurse -Force .\mysql-data
docker compose up -d --build
```

Perhatian: menghapus `mysql-data` akan menghapus semua database lokal.

Jika port bentrok, ubah port di `docker-compose.yml`, misalnya:

```yaml
ports:
  - "8082:80"
```

Lalu jalankan ulang:

```powershell
docker compose up -d
```
