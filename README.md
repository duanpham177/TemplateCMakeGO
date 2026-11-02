# CMakeGO

Ứng dụng Go này được build bằng CMake và các CMake Preset dành cho Windows.

## Yêu cầu

Cài đặt và thêm vào `PATH`:

- Go
- CMake 3.25 trở lên
- Ninja

Để debug trong Visual Studio Code, cài thêm extension **Go** của Go Team at Google và công cụ Delve. Trong VS Code, chạy lệnh **Go: Install/Update Tools**, chọn `dlv` để cài Delve.

## Build

Mở PowerShell hoặc terminal tại thư mục gốc dự án, sau đó chạy:

```powershell
cmake --preset windows-debug
cmake --build --preset windows-debug --target go-app
```

File thực thi được tạo tại `out/build/windows-debug/bin/go-app.exe`.

Để build bản Release:

```powershell
cmake --preset windows-release
cmake --build --preset windows-release --target go-app
```

Có thể dùng script build thay cho hai lệnh trên:

```powershell
.\build.bat
.\build.bat windows-release
```

## Chạy

Để build và chạy ứng dụng qua CMake:

```powershell
cmake --build --preset windows-debug --target go-app_run
```

Hoặc chạy trực tiếp file đã build:

```powershell
.\out\build\windows-debug\bin\go-app.exe
```

## Test

```powershell
cmake --build --preset windows-debug --target go-app_test
```

## Dùng thư mục vendor

Đặt `vendor` trong thư mục module `CMakeGO`, cùng cấp với `go.mod` và mã nguồn:

```text
CMakeGO/
├── CMakeLists.txt
├── go.mod
├── go.sum
├── main.go
├── main_test.go
└── vendor/
    ├── modules.txt
    └── <các package dependency>
```

Không đặt `vendor` ở thư mục gốc cạnh `CMakePresets.json`, vì các lệnh Go chạy từ thư mục module `CMakeGO`.

Khi dự án có dependencies trong `go.mod`, tạo hoặc cập nhật thư mục vendor từ thư mục module:

```powershell
cd .\CMakeGO
go mod tidy
go mod vendor
```

Commit `CMakeGO/vendor` cùng với `go.mod` và `go.sum` nếu muốn lưu dependencies trong repository. Với `go 1.23`, Go tự chọn chế độ vendor khi thư mục `vendor` có file `modules.txt` hợp lệ, nên không cần sửa preset hay CMake. Các lệnh build, run, test và debug ở trên tiếp tục hoạt động; chúng chạy Go với working directory là `CMakeGO`.

Để xác nhận vendor đã đồng bộ với module, chạy:

```powershell
cd .\CMakeGO
go mod vendor
go list -mod=vendor ./...
```

## Debug Go trong Visual Studio Code

1. Mở thư mục gốc dự án trong VS Code.
2. Cài extension **Go** và cài Delve bằng lệnh **Go: Install/Update Tools** nếu chưa có.
3. Mở file Go, đặt breakpoint tại dòng cần dừng.
4. Chọn cấu hình **Debug Go app (CMake)** trong tab **Run and Debug**, rồi nhấn **F5**.

VS Code tự chạy task configure/build `windows-debug` trước khi khởi động Delve. Cấu hình debug nằm trong `.vscode/launch.json`; task build nằm trong `.vscode/tasks.json`.

## Dùng Visual Studio IDE

Mở thư mục gốc dự án bằng **File > Open > Folder**, sau đó dùng cửa sổ **CMake Targets View** để build target `go-app` hoặc chạy target `go-app_run`. Có thể chọn preset `windows-debug` hoặc `windows-release` trong cấu hình CMake của Visual Studio.

Visual Studio IDE có thể dùng để build/chạy dự án CMake này, nhưng không hỗ trợ debug Go bằng breakpoint. Muốn debug từng bước mã Go, hãy dùng Visual Studio Code với Delve như hướng dẫn ở trên.
