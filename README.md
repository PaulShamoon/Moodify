Created By: Paul Shamoon

# Setting Up the Ngrok Server
Moodify uses Ngrok to host our application. 

- Ngrok can be hosted on a local or virtual machine, but these 
instructions will be specific to hosting it on a local physical machine
- The Ngrok server must be running in order to use the facial mood detection feature of Moodify

## Step 1. Create an account
To use Ngrok you need to create an account

- Go to https://ngrok.com/
- Click "Sign up" in the top right corner
- Enter your information and click "Sign up"
- Verify your email if asked to do so
- Fill out the questionnaire

## Step 2. Grabbing the Authtoken
Ngrok provides you with an Authtoken. This is used to authenticate the ngrok agent that you will download in step 3. Make sure to keep it handy, as we will use it in step 4.


## Step 3. Download Ngrok
- Go to this link: https://ngrok.com/download
- Click your respective "OS" Agent (e.g. macOS, Windows, Linux...) 
- Download Ngrok through whichever method you prefer

## Step 4. Configuring your authtoken
- After downloading Ngrok, From Step 2. grab your authtoken and configure it with ngrok through the terminal by running this command
```terminal
ngrok config add-authtoken <token>
```

## Step 5. Setting up Ngrok in the Terminal
- Run this command in the terminal to run ngrok
```terminal
ngrok http 8080
```
- It should look like this
![alt text](image-1.png)
- Everytime you run ngrok again, you have to grab the new url and put it in the "homePageView.swift".

- This is the new url to be used from the previous example https://58db-23-117-48-87.ngrok.free.app

## Step 6. Updating homePageView.swift
- Update this line in homePageView.swift based on what your url is (we're using the example from step 5. in this case)
```swift
struct homePageView: View {
    ...
    let backendURL = "https://58db-23-117-48-87.ngrok-free.app/analyze"
    ...
```
- Ensure you add /analyze to the end of the link, exactly as shown above

## Step 7. Setting up + Running the Virtual Environment
- You must be in the flask folder/directory in order to build the virtual environment
- Run this command in a seperate terminal to build the virtual env
```terminal
python3 -m venv deepface-env
```

- Run this command in the flask folder to activate the virtual env
```terminal
source deepface-env/bin/activate
```

- It should look like this
![alt text](image.png)

## Step 8. Install the needed Packages in the virtual environment
- Install flask
```terminal
pip install flask
```

- Install deepface
```terminal
pip install deepface
```

- Install tf-keras
```terminal
pip install tf-keras
```

## Step 9. Running the flas.py file
- Run this command for the flask file (Note: flask.py doesn't work as a filename since it interferes with the flask library)
```terminal
python3 flas.py
```

## Step 10. Final Result
- Then you should have 2 separate terminals which should look like the following:
    - One running Ngrok (top terminal)
    - The other running flas.py (bottom terminal)
![alt text](image-2.png)

# Set up Spotify Services
In order for our application to use Spotify's iOS SDK and Web API, we need to create a developer app and give our app the "Client ID"

## Step 1. Creating a Spotify developer account
- Go to this link: https://developer.spotify.com
- Press login
- Login with your Spotify Premium account
- If you are a developer looking to test the application, but do not have
  a Spotify Premium account you can use the following developer account
    - Email: paulshamoon@yahoo.com
    - Password: Moodify2024
    - NOTE: This account will deactivate on December 19th, 2024
- After logging in, click the accounts name in the top right corner
- Click "Dashboard"
- Click "Create app"
- Enter "Moodify" for the app name
- Enter "iOS app using facial emotion recognition to create personalized playlists matching the user’s mood" for the description
- Enter "spotify-ios-quick-start://spotify-login-callback" for the redirect URIs
    - Click "Add"
- Click on "Web API" and "iOS" for the API/SDKs section
- Click the checkbox to agree to the terms of service
- Click "Save"
- One the developer app has been created, click "Settings"
- Click "Edit"
- Enter "Moodify" for the iOS app bundle
    - Click "Add"
- Click "Save"

## Step 2. Add the Client ID to Moodify
- Open your developer app in Spotify's developer dashboard
- Under "Basic Information" copy the "Client ID"
- Open Moodify in Xcode
- Navigate to Moodify (Xcode project) > Moodify (contents) > Backend > Controllers > SpotifyController
- Press Command + F and search for "private let spotifyClientID"
- Paste your "Client ID" as a string after the = sign
- The final line of code should look like this:
```swift
    private let spotifyClientID = "YourClientID"
```

# Setting up your iOS device for development
In order to run an application in developement through Xcode, you need to put your iOS device in developer mode

- Go to Settings > Privacy & Security > Developer Mode
- Toggle Developer mode to on
- When prompted to restart your device, press "Restart"
- After device restarts:
    - Swipe up
    - Press "Enable"
    - Enter the devices password if needed


# Installing the application
## Step 1. Sign your device:
- Open the "Moodify" folder in Xcode
- On the top of the file directory for Moodify in Xcode, click "Moodify"
    - Note: There are two Moodify folders, one for the project and one for it's contents. You
            need to click on the Moodify project folder (the first one with the apple icon)
- Click on the "Signing & Capabilities" tab
- Enable "Automatically manage signing" if it is not enabled
- Click "Teams"
- Select your name
- If your name does not appear:
    - Press "Add an Account..."
    - Sign in with your Apple ID
    - Add the newly added personal team
- Create a bundle identifier:
    - Click "Bundle Identifier"
    - Enter "Moodify"

## Step 2. Install the app:
- Connect your iOS device to your Mac through a compatible wire
- In Xcode on the very top, click on where it says "iPhone" or "Any iOS Device (arm64)
    - From the dropdown, select the iOS device you connected
- While in Xcode press the play button on the top left, or enter the following shortcut:
    - Command + R
- NOTE: The first time you build an app usually takes a minute or two
- If an error appears on your iOS device saying "Untrusted Developer" do the following:
    - Press "Cancel" on the pop up error
    - Go to Settings > General > VPN & Device Management
    - Press on the email associated with your Apple ID that you used to sign your device
    - Press "Trust"
    - Press "Allow
