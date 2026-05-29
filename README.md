# GABLER

**GABLER** adalah singkatan dari **General App Backend Laravel Environment Runner**.

GABLER adalah tools lokal berbasis Docker untuk menjalankan environment PHP, Nginx, MySQL, phpMyAdmin, dan Laravel secara praktis.

# PHP, Nginx, MySQL, phpMyAdmin, and Laravel Docker Stack

Stack ini dibuat seperti lingkungan XAMPP, tetapi menggunakan Docker Compose.

## Isi Stack

- Nginx: web server di `http://localhost:8080`
- PHP-FPM: menjalankan file PHP dan Laravel
- MySQL: database di port `3306`
- phpMyAdmin: database manager di `http://localhost:8081`
- Laravel: contoh project di `www/laravel`

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
    +-- laravel\
```

Keterangan:

- `www/index.php` adalah halaman utama.
- `www/laravel` adalah project Laravel.
- `mysql-data` menyimpan data MySQL agar tidak hilang saat container dimatikan.
- `nginx/default.conf` adalah konfigurasi Nginx.
- `php/Dockerfile` adalah image PHP custom dengan ekstensi MySQL.

## Install Docker

1. Download Docker Desktop:
   `https://www.docker.com/products/docker-desktop/`
2. Install Docker Desktop.
3. Aktifkan WSL 2 jika diminta oleh installer Docker Desktop.
4. Restart komputer jika diminta.
5. Buka Docker Desktop dan tunggu sampai statusnya running.
6. Cek instalasi lewat PowerShell:

```powershell
docker --version
docker compose version
```

Jika dua command di atas menampilkan versi Docker, berarti Docker siap dipakai.

## Menjalankan Stack

Buka PowerShell, lalu masuk ke folder project:

```powershell
cd c:\etc
```

Jalankan semua service:

```powershell
docker compose up -d --build
```

Tunggu sampai semua container aktif, lalu cek:

```powershell
docker compose ps
```

## URL Akses

- Halaman utama: `http://localhost:8080`
- Laravel: `http://localhost:8080/laravel/public/`
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

Atau gunakan:

```text
Username: appuser
Password: apppass
```

## Command Docker Compose Harian

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

Melihat log semua service:

```powershell
docker compose logs
```

Melihat log service tertentu:

```powershell
docker compose logs nginx
docker compose logs php
docker compose logs mysql
docker compose logs phpmyadmin
```

Melihat log real-time:

```powershell
docker compose logs -f
```

Restart semua service:

```powershell
docker compose restart
```

Restart service tertentu:

```powershell
docker compose restart nginx
docker compose restart php
docker compose restart mysql
docker compose restart phpmyadmin
```

Masuk ke container PHP:

```powershell
docker compose exec php sh
```

Menjalankan command PHP di container:

```powershell
docker compose exec php php -v
```

Masuk ke MySQL dari container:

```powershell
docker compose exec mysql mysql -uroot -prootpass
```

Mematikan container tanpa menghapus data:

```powershell
docker compose down
```

Menghapus container dan network, tetapi data MySQL tetap aman karena ada di folder `mysql-data`:

```powershell
docker compose down
```

Menghapus container, network, dan image yang tidak dipakai:

```powershell
docker system prune
```

Gunakan command di atas dengan hati-hati.

## Fresh Install Laravel

Folder `www/laravel/vendor` tidak ikut disimpan ke Git karena ukurannya besar. Jadi setelah clone repository atau menjalankan project di komputer baru, Laravel bisa menampilkan error seperti ini:

```text
Warning: require(/var/www/html/laravel/public/../vendor/autoload.php): Failed to open stream: No such file or directory
```

Artinya dependency Laravel belum di-install.

Jalankan langkah berikut dari folder root project:

```powershell
cd c:\etc
docker compose up -d --build
docker run --rm -v ${PWD}\www\laravel:/app composer install
```

Buat file `.env` dari `.env.example`:

```powershell
Copy-Item .\www\laravel\.env.example .\www\laravel\.env
```

Edit `www\laravel\.env`, lalu sesuaikan database agar memakai MySQL Docker:

```env
APP_URL=http://localhost:8080/laravel/public

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=appdb
DB_USERNAME=appuser
DB_PASSWORD=apppass
```

Setelah itu generate application key dan jalankan migration:

```powershell
docker compose exec php sh -lc "cd /var/www/html/laravel && php artisan key:generate"
docker compose exec php sh -lc "cd /var/www/html/laravel && php artisan migrate"
```

Jika Laravel masih error karena cache lama:

```powershell
docker compose exec php sh -lc "cd /var/www/html/laravel && php artisan optimize:clear"
```

Setelah selesai, buka:

```text
http://localhost:8080/laravel/public/
```

## Command Laravel

Masuk ke folder Laravel di container PHP:

```powershell
docker compose exec php sh
cd /var/www/html/laravel
```

Atau jalankan langsung dari PowerShell:

```powershell
docker compose exec php sh -lc "cd /var/www/html/laravel && php artisan about"
```

Menjalankan migration:

```powershell
docker compose exec php sh -lc "cd /var/www/html/laravel && php artisan migrate"
```

Clear cache Laravel:

```powershell
docker compose exec php sh -lc "cd /var/www/html/laravel && php artisan optimize:clear"
```

Optimize Laravel:

```powershell
docker compose exec php sh -lc "cd /var/www/html/laravel && php artisan optimize"
```

## Menambah Project Web Lain

Untuk project PHP biasa, buat folder baru di `www`, misalnya:

```text
www\project-baru\index.php
```

Akses:

```text
http://localhost:8080/project-baru/
```

Untuk project Laravel lain, letakkan seperti ini:

```text
www\nama-laravel\
```

Akses folder public:

```text
http://localhost:8080/nama-laravel/public/
```

## Catatan Performa Laravel di Windows

Laravel bisa terasa lambat jika project berada di filesystem Windows seperti `C:\...` dan dijalankan melalui Docker Desktop. Ini karena Laravel membaca banyak file kecil dari folder `vendor`.

Solusi yang bisa membantu:

```powershell
docker compose exec php sh -lc "cd /var/www/html/laravel && php artisan optimize"
```

Jika ingin lebih cepat untuk development, simpan project di filesystem WSL, bukan di drive `C:\`.

## Troubleshooting

Jika web tidak bisa dibuka:

```powershell
docker compose ps
docker compose logs nginx
docker compose logs php
```

Jika Laravel error setelah memindahkan file:

```powershell
docker compose exec php sh -lc "cd /var/www/html/laravel && chmod -R 777 storage bootstrap/cache && php artisan optimize:clear"
```

Jika MySQL belum siap:

```powershell
docker compose logs mysql
```

Jika phpMyAdmin menampilkan error koneksi seperti:

```text
phpMyAdmin tried to connect to the MySQL server, and the server rejected the connection.
```

Cek status MySQL:

```powershell
docker compose ps
docker compose logs mysql
```

Pastikan MySQL berstatus `healthy`. Jika folder `mysql-data` sudah pernah dibuat dengan password lama, environment di `docker-compose.yml` tidak akan mengubah password database yang sudah ada. Untuk reset database lokal dari awal, matikan stack lalu hapus folder `mysql-data`:

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
