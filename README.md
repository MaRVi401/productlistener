# Aplikasi POS (Point of Sale) - Flutter & MobX

Aplikasi POS sederhana berbasis Flutter yang menerapkan prinsip **Clean Architecture** serta manajemen state menggunakan **MobX**. Aplikasi ini terintegrasi dengan backend Backend-as-a-Service (BaaS) **Directus** untuk menangani autentikasi token, manajemen produk (CRUD), hingga pengunggahan media gambar (*Multipart file upload*).

---

## 🛠️ Fitur Utama

- **Authentication Service**: Login otomatis berbasis Bearer Token.
- **Product Management (CRUD)**:
  - **Create**: Menambahkan produk baru beserta gambar produk.
  - **Read**: Menampilkan daftar produk, detail produk, serta agregasi data (total produk & total harga).
  - **Update**: Mengubah informasi produk dan mengganti foto produk.
  - **Delete**: Menghapus produk dengan fitur *Optimistic Update* dan animasi *Dismissible*.
- **Media Upload**: Pengunggahan foto produk dari galeri lokal ke Directus Asset Storage via `image_picker`.
- **State Management**: MobX dengan dukungan pilar utama (*Observable, Action, Computed, & Reaction*).

---

## ⚡ Implementasi MobX State Management

Aplikasi ini mengimplementasikan 4 pilar utama MobX secara utuh di dalam `lib/presentation/mobx/product_store.dart`:

1. **`@observable` (State Tracking)**
   - `products`: `ObservableList<Product>` — Menyimpan daftar produk yang dipantau secara reaktif oleh UI.
   - `isLoading`: `bool` — Menandai status proses async/API.
   - `errorMessage`: `String?` — Menampung pesan error jika terjadi kendala API.

2. **`@action` (State Mutation)**
   - `fetchProducts()` — Mengambil data produk dari backend.
   - `addNewProduct()` — Menambah produk baru beserta pengunggahan file gambar.
   - `editProduct()` — Memperbarui data produk dan foto produk.
   - `removeProduct()` — Menghapus produk dengan *optimistic update*.

3. **`@computed` (Derived State)**
   - `totalProducts` — Menghitung jumlah item produk secara otomatis dan efisien (`products.length`).
   - `totalPrice` — Akumulasi total harga seluruh produk (`products.fold(...)`).

4. **`Reaction` (Side Effects)**
   - Menggunakan `reaction` pada konstruktor `_ProductStore()` untuk mendeteksi perubahan pada `errorMessage` dan otomatis mencetak log debug/sampingan tanpa merusak alur pembentukan UI:
     ```dart
     reaction((_) => errorMessage, (String? message) {
       if (message != null && message.isNotEmpty) {
         debugPrint("[REACTION LOG]: Exception/Error terjadi - $message");
       }
     });
     ```

---

## 🏗️ Arsitektur Proyek (Clean Architecture)

Proyek ini disusun mengikuti arsitektur Clean Architecture yang terbagi menjadi 3 lapisan utama (*Core/Data, Domain, Presentation*):

```text
lib/
├── core/
│   └── network/
│       └── api_service.dart          # Penanganan HTTP Request & Bearer Auth
├── data/
│   ├── datasources/
│   │   └── product_remote_datasource.dart # Komunikasi langsung dengan API Endpoints
│   ├── models/
│   │   └── product_model.dart        # Parsing JSON & pemetaan data
│   └── repositories/
│       └── product_repository_impl.dart # Implementasi interface dari domain
├── domain/
│   ├── entities/
│   │   └── product.dart              # Model bisnis utama (Entity)
│   ├── repositories/
│   │   └── product_repository.dart   # Kontrak interface repository
│   └── usecases/
│       ├── add_product.dart          # Usecase: Tambah Produk
│       ├── delete_product.dart       # Usecase: Hapus Produk
│       ├── get_products.dart         # Usecase: Ambil Daftar Produk
│       ├── update_product.dart       # Usecase: Update Produk
│       └── upload_image.dart         # Usecase: Upload Gambar
├── presentation/
│   ├── mobx/
│   │   ├── product_store.dart        # MobX Store (Actions, Observables, Computed, Reactions)
│   │   └── product_store.g.dart      # Generated code oleh build_runner
│   ├── pages/
│   │   ├── add_product_page.dart     # Halaman Form Tambah Produk & Picker Gambar
│   │   ├── home_page.dart            # Halaman Utama/Dashboard
│   │   ├── product_list_page.dart    # Halaman Daftar Produk & Modal Detail/Edit
│   │   └── tantangan_page.dart       # Halaman Tantangan
│   └── widgets/
│       └── product_card.dart         # Widget Reusable Komponen Kartu Produk
└── main.dart                         # Entry point & Dependency Injection manual

```

---

## 🚀 Fitur & Modul Teknis

| Layer | Komponen | Deskripsi |
| --- | --- | --- |
| **Core** | `ApiService` | Menangani koneksi HTTP, penyimpan token sementara, serta eksekusi `MultipartRequest` untuk upload file. |
| **Data** | `ProductModel` | Mengolah penyesuaian tipe data dari backend (misal conversion `num` ke `double` dan pembuatan URL asset Directus). |
| **Domain** | `UseCases` | Memisahkan logika bisnis aplikasi menjadi potongan aksi yang terisolasi. |
| **Presentation** | `ProductStore` | Mengelola *reactive state* aplikasi dan menangani *optimistic update* UI saat aksi hapus/update. |

---

## 💻 Cara Menjalankan Proyek

### 1. Prasyarat

* Flutter SDK (Versi terbaru)
* Dart SDK
* Android Studio / VS Code
* Emulator atau Perangkat Fisik Android/iOS

### 2. Instalasi Dependensi

Jalankan perintah berikut di terminal proyek:

```bash
flutter pub get

```

### 3. Generate MobX Store

Aplikasi ini menggunakan MobX code generator. Setiap ada perubahan pada `product_store.dart`, jalankan perintah berikut:

```bash
flutter pub run build_runner build --delete-conflicting-outputs

```

### 4. Konfigurasi Izin Android

Pastikan izin membaca penyimpanan media sudah terdaftar di `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

```

### 5. Jalankan Aplikasi

```bash
flutter run

```

---

## ⚙️ Dependensi Utama

* [`flutter_mobx`](https://pub.dev/packages/flutter_mobx?utm_source=gemini) & [`mobx`](https://pub.dev/packages/mobx?utm_source=gemini) - State Management
* [`http`](https://pub.dev/packages/http?utm_source=gemini) - HTTP Client untuk REST API
* [`image_picker`](https://pub.dev/packages/image_picker?utm_source=gemini) - Pemilihan gambar dari Galeri / Kamera
* [`build_runner`](https://pub.dev/packages/build_runner?utm_source=gemini) & [`mobx_codegen`](https://pub.dev/packages/mobx_codegen?utm_source=gemini) - Generator Kode MobX