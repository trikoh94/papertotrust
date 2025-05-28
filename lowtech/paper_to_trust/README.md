# 📱 PaperToTrust

A trust-centered Flutter app for elderly micro-entrepreneurs who prefer handwritten ledgers but need light-touch digital support.

## 🧓 About the App

**PaperToTrust** is a minimal, human-centered mobile app that lets elderly shopkeepers take a photo of their handwritten bookkeeping page and send it to a trusted assistant for manual digitization.

Unlike most accounting tools, this app does **not assume technical fluency**.  
Instead, it aims to create a **"trust bridge"** between analog and digital practices — by preserving familiar habits and embedding human review into the workflow.

## 🎯 Key Objectives

- Respect paper-based habits while supporting gradual digital inclusion
- Build digital trust through warm, human feedback — not automation alone
- Address civic inequity by including those excluded by default digital systems

## 👤 Target Users

This app is for:

- Elderly store owners and micro-entrepreneurs in Japan  
- Users who still rely on paper ledgers due to trust, fear, or cultural comfort  
- Families helping their elders manage financial records  
- Civic organizations addressing digital exclusion

## 🛠 Core Features

- 📸 **Take or upload** a photo of a paper ledger  
- 📝 **Add a memo** or comment to help with review  
- ☁️ **Upload securely** to a server (manual review follows)  
- 👩‍💻 **Human assistant** digitizes the entry and sends feedback  
- 🔔 **Receive responses** with a warm message or correction  
- 🖨️ Optional PDF export of reviewed summary

## 🧭 Civic Design Context

This app was created as part of a **civic-tech research project** on digital resistance and trust transfer in aging societies.  
It's not meant to replace analog systems, but to **support inclusion** without demanding full digital literacy.

The question it explores:

> "Can trust in paper-based systems be gradually transferred — not by replacing habits, but by building human-centered support around them?"

## 💻 Tech Stack

- [x] Flutter (Android, iOS, Web)
- [x] `image_picker` / `camera`
- [x] Cloudinary for file storage
- [x] `flutter_tts` for optional audio support
- [x] `provider` for state management

## 🚀 Getting Started

1. Clone the repository
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Create a `.env` file in the root directory with your Cloudinary credentials:
   ```
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 📬 Contact

This project is part of a research collaboration on civic digital inclusion.  
To contribute, test, or inquire about localization, please contact:

**Minjin & Suyeon**  
📧 `digitrust.project@gmail.com`

---

> *Technology doesn't create trust. People do.*  
> This app builds around that idea.
