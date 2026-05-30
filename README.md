# GABLER

**GABLER** adalah singkatan dari **General App Backend Local Environment Runner**.

GABLER adalah template environment lokal berbasis Docker untuk menjalankan project backend PHP dengan Nginx, MySQL, MongoDB, Redis, phpMyAdmin, mongo-express, dan Redis Commander. Project web dapat dibuat sendiri di folder `www`.

## Isi Stack

- Nginx: web server di `http://localhost:8080`
- PHP-FPM: menjalankan file PHP
- MySQL: database di port `3306`
- phpMyAdmin: database manager di `http://localhost:8081`
- MongoDB: database dokumen di port `27017`
- mongo-express: MongoDB web manager di `http://localhost:8082`
- Redis: cache, session, dan queue di port `6379`
- Redis Commander: Redis web manager di `http://localhost:8083`

## Struktur Folder

```text
c:\etc
+-- docker-compose.yml
+-- README.md
+-- mysql-data\
+-- mongodb-data\
+-- redis-data\
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
- `mongodb-data` menyimpan data MongoDB lokal.
- `redis-data` menyimpan data Redis lokal.
- `nginx/default.conf` adalah konfigurasi Nginx.
- `php/Dockerfile` adalah image PHP custom dengan ekstensi MySQL, MongoDB, dan Redis.

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
- mongo-express: `http://localhost:8082`
- Redis Commander: `http://localhost:8083`

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
- mongo-express: `http://localhost:8082`
- Redis Commander: `http://localhost:8083`

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

## Database MongoDB

Credential MongoDB:

```text
Host dari container PHP: mongodb
Host dari komputer lokal: localhost
Port: 27017
Database default: appdb
Root user: root
Root password: rootpass
Connection string dari PHP: mongodb://root:rootpass@mongodb:27017/?authSource=admin
```

Login mongo-express:

```text
URL: http://localhost:8082
Username: admin
Password: adminpass
```

Halaman utama GABLER juga menampilkan daftar collection MongoDB di database `appdb` dan menyediakan form sederhana untuk membuat collection baru.

## Database Redis

Credential Redis:

```text
Host dari container PHP: redis
Host dari komputer lokal: localhost
Port: 6379
Password: kosong
```

Redis Commander:

```text
URL: http://localhost:8083
```

Contoh konfigurasi Laravel `.env`:

```env
CACHE_STORE=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
```

Halaman utama GABLER juga menampilkan status koneksi Redis dari container PHP.

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
docker compose restart mongodb
docker compose restart mongo-express
docker compose restart redis
docker compose restart redis-commander
```

Masuk ke container PHP:

```powershell
docker compose exec php sh
```

Masuk ke MySQL:

```powershell
docker compose exec mysql mysql -uroot -prootpass
```

Masuk ke MongoDB:

```powershell
docker compose exec mongodb mongosh -u root -p rootpass --authenticationDatabase admin
```

Masuk ke Redis:

```powershell
docker compose exec redis redis-cli
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

Cara paling mudah di Windows adalah menjalankan:

```text
create-laravel.bat
```

Script akan meminta nama app Laravel, lalu otomatis:

- menjalankan Docker service
- membuat project Laravel di `www\nama-app`
- membuat file `.env`
- mengatur koneksi database ke MySQL Docker
- menjalankan `php artisan key:generate`
- mengatur permission `storage` dan `bootstrap/cache`
- menawarkan pilihan untuk menjalankan migration

Contoh:

```text
Masukkan nama app Laravel: toko-online
```

Akses:

```text
http://localhost:8080/toko-online/public/
```

Cara manual membuat Laravel baru di folder `www`:

```powershell
cd c:\etc
docker compose up -d --build php
docker compose exec php sh -lc "cd /var/www/html && composer create-project laravel/laravel nama-project"
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

## Menambah Project Yii2

Cara paling mudah di Windows adalah menjalankan:

```text
create-yii.bat
```

Script akan meminta nama app Yii2, lalu otomatis:

- menjalankan Docker service
- membuat project Yii2 basic di `www\nama-app`
- mengatur koneksi database ke MySQL Docker
- mengatur permission `runtime` dan `web/assets`

Contoh:

```text
Masukkan nama app Yii2: yii-app
```

Akses:

```text
http://localhost:8080/yii-app/web/
```

Cara manual:

```powershell
cd c:\etc
docker compose up -d --build php
docker compose exec php sh -lc "cd /var/www/html && composer create-project yiisoft/yii2-app-basic yii-app"
docker compose exec php sh -lc "cd /var/www/html/yii-app && chmod -R 777 runtime web/assets"
```

Setelah itu edit `www\yii-app\config\db.php` agar memakai:

```php
'dsn' => 'mysql:host=mysql;dbname=appdb',
'username' => 'appuser',
'password' => 'apppass',
```

## Menambah Project CodeIgniter 4

Cara paling mudah di Windows adalah menjalankan:

```text
create-ci.bat
```

Script akan meminta nama app CodeIgniter, lalu otomatis:

- menjalankan Docker service
- membuat project CodeIgniter 4 di `www\nama-app`
- membuat file `.env`
- mengatur koneksi database ke MySQL Docker
- mengatur permission `writable`
- menawarkan pilihan untuk menjalankan migration

Contoh:

```text
Masukkan nama app CodeIgniter: ci-app
```

Akses:

```text
http://localhost:8080/ci-app/public/
```

Cara manual:

```powershell
cd c:\etc
docker compose up -d --build php
docker compose exec php sh -lc "cd /var/www/html && composer create-project codeigniter4/appstarter ci-app"
```

Setelah itu copy `env` menjadi `.env`, lalu edit database:

```env
CI_ENVIRONMENT = development
app.baseURL = 'http://localhost:8080/ci-app/public/'

database.default.hostname = mysql
database.default.database = appdb
database.default.username = appuser
database.default.password = apppass
database.default.DBDriver = MySQLi
database.default.port = 3306
```

## Menggunakan Composer

GABLER menyediakan wrapper `composer.bat`, sehingga pengguna tidak perlu mengetik command Docker yang panjang.

Jika ingin menjalankan Composer di dalam project, masuk ke folder project terlebih dahulu:

```powershell
cd c:\etc\www\nama-project
```

Lalu jalankan Composer seperti biasa:

```powershell
..\composer.bat install
..\composer.bat require vendor/package
..\composer.bat update
```

Contoh install package Laravel:

```powershell
cd c:\etc\www\toko-online
..\composer.bat require laravel/breeze
```

Wrapper tersebut akan menjalankan Composer lewat container Docker:

```powershell
docker compose exec php sh -lc "cd /var/www/html/nama-project && composer ..."
```

Jadi versi Composer dan PHP yang dipakai tidak bergantung pada Composer lokal di komputer, dan extension seperti `intl` mengikuti PHP GABLER.

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
