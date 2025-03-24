# FixMyCity 

## Introduction
FixMyCity is a smart city utility management application designed to empower citizens by providing a seamless platform to report civic issues. The app allows users to register complaints by uploading images and details of affected areas, ensuring that local authorities can quickly identify and resolve issues.

With features like real-time tracking, role-based notifications, and machine learning-powered complaint analysis, FixMyCity enhances transparency, accountability, and efficiency in urban issue resolution.

### Figma link of Prototype - 
https://www.figma.com/design/wNC29tbOgDAyEqDqPiXp8U/FixMyCity?node-id=2-2&t=DT3fbb9MicQVj1gr-1

## Features
### For Users:
- Register and log complaints with photo attachments.
- Real-time complaint status updates.
- Easy tracking of issue resolution.

### For Administrators:
- Receive and manage complaints.
- Assign complaints to workers.
- Mark complaints as resolved only after verification.

### For Workers:
- Receive assigned complaints.
- Resolve complaints and submit proof with images and feedback.
- Complaints can only be marked resolved after verification.

## Unique Features
1. **Multi-Role Dynamic Workflow**: Custom interfaces and functionalities for users, workers, and admins.
2. **Complaint Submission with Geotagging**: Automatically logs user location and provides Google Maps navigation for workers.
3. **Visual Proof-Based Resolution**: Workers must upload completion images and feedback to ensure transparency.
4. **Role-Based Notifications**: Real-time alerts for complaint updates, assignments, and resolutions.
5. **Real-Time Status Tracking**: Live updates on complaint progress.
6. **Admin Feedback Validation**: Admins review submissions and ML-based complaint criticality before closure.
7. **Firestore-Driven Modular Data Architecture**: Structured storage for complaints, images, and feedback.

## Methodology
1. **Requirement Analysis**: Identify key features (user login, complaint logging, admin dashboard).
2. **UI/UX Design**: Create interactive prototypes using Figma.
3. **Frontend Development**: Build app interface using Flutter and Dart.
4. **Backend Setup**: Use Firebase Firestore for database management and Firebase Storage for image storage.
5. **Machine Learning Integration**: Train an ML model (MobileNetV2) with TensorFlow to estimate workforce requirements based on complaint photos.
6. **Testing**: Perform unit testing and integration testing using Flutter testing libraries.
7. **Deployment**: Deploy on Play Store and App Store, integrate GitHub for version control.
8. **Feedback & Iteration**: Gather user feedback and refine the app based on input.

## Tools & Technologies Used
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Firestore (Database), Firebase Storage (Image Storage), Firebase Authentication
- **Machine Learning**: TensorFlow (MobileNetV2 for complaint criticality prediction)
- **UI/UX**: Figma

## Scope
FixMyCity can be applied in:
- Urban city management systems.
- Residential societies and gated communities.
- Industrial zones and public spaces.
- Integration with municipal corporations’ existing platforms.

## Target Audience
- Urban residents looking for quick solutions to daily issues.
- Municipal corporations aiming for efficient resource management.
- Contractors and workforce teams responsible for on-ground work.
- Environmental organizations tracking urban cleanliness initiatives.
