# ChapterClip

[English README](README.md)

ChapterClip 用来导入 EPUB 电子书，把章节拆成适合复制的小段，记录阅读进度，并快速复制文本内容。

当前仓库包含两个版本：

- `android/` 和 `lib/`：Android Flutter 应用。
- `web-pwa/`：纯 Web PWA 版本，使用 Svelte 实现。

HarmonyOS、iOS、Windows 和桌面端目标都没有包含在公开仓库中。

## 功能

- 通过 Android 系统文件选择器导入 EPUB 文件。
- 读取 EPUB 元数据、spine 阅读顺序、目录标题和 XHTML 章节内容。
- 从章节 HTML 中提取可阅读的段落文本。
- 按目标字符数把章节拆分成文本块，并尽量保持段落边界。
- 按书籍、章节、文本块和段落记录阅读进度。
- 支持把文本块标记为已读或未读。
- 支持复制文本块内容和基础元信息。
- 使用 Drift 和 SQLite 在本地保存导入内容。
- 支持可选的 APK 应用内更新检查，更新源由 `update.json` 描述。
- 提供纯 Web PWA 版本，可在浏览器中完成 EPUB 导入、分块、进度记录和复制。

## 技术栈

- Flutter 和 Dart
- Android Kotlin 宿主代码
- Drift 本地数据库
- `sqlite3_flutter_libs` 提供 SQLite 运行时
- `file_selector` 调用 Android 文件选择器
- `archive`、`xml`、`html` 解析 EPUB
- Riverpod 管理应用级依赖

## 环境要求

- Flutter stable SDK
- Flutter 自带 Dart SDK
- Android Studio 或 Android 命令行工具
- 已安装较新的 Android SDK / compile SDK
- JDK 17
- Android 真机或模拟器

先检查本机环境：

```powershell
flutter doctor
```

## 快速开始

克隆仓库并安装依赖：

```powershell
git clone https://github.com/oldkingnearby/chapterclip.git
cd chapterclip
flutter pub get
```

连接 Android 设备后运行：

```powershell
flutter run
```

构建 release APK：

```powershell
flutter build apk --release
```

也可以使用项目里的 PowerShell 构建脚本：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build-android.ps1 -Mode release
```

默认 APK 输出位置：

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Web PWA

纯 Web 版本在 `web-pwa/` 目录下：

```powershell
cd web-pwa
npm install
npm run dev
```

构建静态 PWA：

```powershell
npm run build
```

构建结果在 `web-pwa/dist/`，可以部署到任意静态托管服务。

## 可选自动更新

公开仓库默认关闭应用内更新检查。这样做是为了避免把个人发布域名、R2 bucket、上传脚本或密钥相关逻辑放进 public repo。

如果你要启用自动更新，需要在构建时传入公开访问的更新目录：

```powershell
flutter build apk --release --dart-define=CHAPTERCLIP_UPDATE_BASE_URL=https://example.com/chapterclip/
```

或者使用构建脚本：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build-android.ps1 -Mode release -UpdateBaseUrl https://example.com/chapterclip/
```

应用会在这个目录下读取 `update.json`：

```json
{
  "version": "1.0.2",
  "buildNumber": 3,
  "apk": "chapterclip-android.apk",
  "notes": "修复 Android content URI EPUB 导入问题。",
  "force": false
}
```

字段说明：

- `version`：版本号，不包含 `+buildNumber`。
- `buildNumber`：Android versionCode。
- `apk`、`apkUrl`、`url` 或 `fileName`：APK 文件名、相对路径或完整 URL。
- `notes`：可选更新说明。
- `force`：可选，设为 `true` 时更新弹窗不可跳过。

公开仓库不包含任何 R2、S3 或其他存储平台的上传脚本。你可以用自己的私有脚本、CI Secret 或手动上传流程发布 APK 和 manifest。

## EPUB 导入说明

Android 文件选择器经常返回 `content://` URI，而不是普通文件路径。ChapterClip 会先通过 `XFile.readAsBytes()` 读取文件字节，再解析 EPUB，所以可以兼容下载目录、媒体文档、系统文件管理器和其他 Android document provider。

导入过程离线完成，不会上传书籍内容。应用会尽量保留源文件名，并把解析出的书籍、章节、段落和文本块保存到本地数据库。

## 项目结构

```text
android/                         Android 宿主工程
web-pwa/                         纯 Web PWA 实现
assets/                          应用资源
lib/app.dart                     应用入口 UI 和主题
lib/data/database/               Drift 表结构、DAO、生成代码
lib/epub/                        EPUB 解析、HTML 文本提取、文本块拆分
lib/features/book/               书籍、章节、文本块页面
lib/features/import/             EPUB 导入服务
lib/features/library/            书库页面和文件选择流程
lib/services/app_update_service.dart
lib/utils/app_update_flow.dart
scripts/build-android.ps1        本地 Android 构建脚本
test/                            解析、导入和数据库测试
```

## 开发

修改 Drift 数据表后重新生成数据库代码：

```powershell
dart run build_runner build --delete-conflicting-outputs
```

运行静态检查：

```powershell
flutter analyze lib test
```

运行测试：

```powershell
flutter test
```

## Android 包名

当前 Android 包名在 `android/app/build.gradle.kts` 中配置。发布自己的 fork 前，请按需要修改 `namespace` 和 `applicationId`。

## 许可证

当前还没有选择许可证。如果要复用、分发或二次发布，请先添加明确的开源许可证。
