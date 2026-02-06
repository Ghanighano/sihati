# Sihati (صحتي) — Clean MVP (يبني APK بدون أخطاء)

هذه نسخة "نظيفة" الهدف منها: **يبني APK على GitHub Actions بدون مشاكل**.
- لا تحتوي Firebase ولا Google Maps في هذه المرحلة (نضيفهم لاحقاً بعد ما نضمن الـCI ثابت).
- فيها واجهة حديثة + بحث (تخصص/ولاية/بلدية) + صفحة طبيب + طلب موعد + مواعيدي.

## كيف تطلع APK من GitHub
1) ارفع كل الملفات إلى Repo جديد (أو امسح القديم وارفع هذا).
2) افتح Actions وشغّل Workflow: **Build Android APK (Sihati Clean)**
3) بعد النجاح ✅ حمّل Artifact: `sihati-apk` وفيه `app-release.apk`

## لاحقًا (خطوة بخطوة)
- إضافة Firebase Phone Auth
- إضافة Google Maps + compileSdk 36
- إضافة Admin approvals + Doctor dashboard + Visit Code
