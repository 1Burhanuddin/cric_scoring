#!/bin/bash

# Firebase Setup Script for Cric Scoring App
# This script helps automate Firebase setup steps

echo "🔥 Firebase Setup for Cric Scoring App"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
echo "📱 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter is installed${NC}"
echo ""

# Check if Firebase CLI is installed
echo "🔥 Checking Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    echo -e "${YELLOW}⚠️  Firebase CLI is not installed${NC}"
    echo "Install it with: npm install -g firebase-tools"
    read -p "Do you want to continue without Firebase CLI? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✅ Firebase CLI is installed${NC}"
    firebase --version
fi
echo ""

# Check if FlutterFire CLI is installed
echo "🔥 Checking FlutterFire CLI..."
if ! command -v flutterfire &> /dev/null; then
    echo -e "${YELLOW}⚠️  FlutterFire CLI is not installed${NC}"
    echo "Installing FlutterFire CLI..."
    dart pub global activate flutterfire_cli
else
    echo -e "${GREEN}✅ FlutterFire CLI is installed${NC}"
fi
echo ""

# Get Flutter packages
echo "📦 Getting Flutter packages..."
flutter pub get
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Packages installed${NC}"
else
    echo -e "${RED}❌ Failed to get packages${NC}"
    exit 1
fi
echo ""

# Check for google-services.json
echo "🔍 Checking for google-services.json..."
if [ -f "android/app/google-services.json" ]; then
    echo -e "${GREEN}✅ google-services.json found${NC}"
else
    echo -e "${YELLOW}⚠️  google-services.json not found${NC}"
    echo "Please download it from Firebase Console and place it in android/app/"
fi
echo ""

# Check for GoogleService-Info.plist
echo "🔍 Checking for GoogleService-Info.plist..."
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✅ GoogleService-Info.plist found${NC}"
else
    echo -e "${YELLOW}⚠️  GoogleService-Info.plist not found${NC}"
    echo "Please download it from Firebase Console and add it to Xcode project"
fi
echo ""

# Offer to run FlutterFire configure
echo "🔧 Firebase Configuration"
read -p "Do you want to run 'flutterfire configure' now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    flutterfire configure
    echo ""
fi

# Install iOS pods (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Installing iOS pods..."
    cd ios
    pod install
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ iOS pods installed${NC}"
    else
        echo -e "${RED}❌ Failed to install pods${NC}"
    fi
    cd ..
    echo ""
fi

# Offer to deploy Firebase rules
if command -v firebase &> /dev/null; then
    echo "🔒 Firebase Rules Deployment"
    read -p "Do you want to deploy Firestore rules and indexes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Logging into Firebase..."
        firebase login
        
        echo "Deploying Firestore rules..."
        firebase deploy --only firestore:rules
        
        echo "Deploying Firestore indexes..."
        firebase deploy --only firestore:indexes
        
        echo "Deploying Storage rules..."
        firebase deploy --only storage
        
        echo -e "${GREEN}✅ Rules deployed${NC}"
    fi
    echo ""
fi

# Summary
echo "📋 Setup Summary"
echo "================"
echo ""
echo "Next steps:"
echo "1. Ensure google-services.json is in android/app/"
echo "2. Ensure GoogleService-Info.plist is added to Xcode"
echo "3. Update lib/firebase_options.dart with correct values"
echo "4. Run: flutter run"
echo "5. Test Firebase connection using the Firebase Test Screen"
echo ""
echo "For detailed instructions, see FIREBASE_SETUP.md"
echo ""
echo -e "${GREEN}✅ Setup script completed!${NC}"
