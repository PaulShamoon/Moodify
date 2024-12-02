# Setting Up the Ngrok Server
Moodify uses Ngrok to host our application. 

- Ngrok can be hosted on a local or virtual machine, but these 
instructions will be specific to hosting it on a local physical machine
- The Ngrok server must be running in order to use the facial mood detection feature of Moodify

## Create an account
To use Ngrok you need to create an account

- Go to https://ngrok.com/
- Click "Sign up" in the top right corner
- Enter your information and click "Sign up"
- Verify your email if asked to do so
- Fill out the questionairre

## Grabing the Authtoken
Ngrok provides you with an Authtoken. This is used to authenticate the ngrok agent that you downloaded


## Download Ngrok
- Go to this link: https://ngrok.com/download
- Click "macOS"
- Click the "Download" tab
- Click "Download" towards the right of the page 

## Set Up and Run the Virtual Enviorment
Kidd: talk about how to setup and run the virtual enviorment

## Install the needed Packages
Kidd: describe what packages need to be installed in the virtual env

## Setup the flask.py file
Kidd: describe how to setup the flask.py file

## Running the Server
Kidd: describe how to actually run the server

## Set the correct url in Moodify
Kidd: Describe how to copy the url from ngrok and where you need to go in moodify and paste it

# Set up Spotify Services
In order for our application to use Spotify's iOS SDK and Web API, we need to create a developer app and give our app the "Client ID"

## Creating a Spotify developer account
- Go to this link: https://developer.spotify.com
- Press login
- Login with your Spotify Premium account
- If you are a developer looking to test the application, but do not have
  a Spotify Premium account you can use the following developer account
    - Email: paulshamoon@yahoo.com
    - Passowrd: Moodify2024
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

## Add the Cleint ID to Moodify
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
## Sign your device:
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

## Install the app:
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


# Kidd: Old readme instructions, should be deleted after updating the above sections
Once you create an account, grab your auth token here and add the authtoken
![alt text](image-3.png)


## Setting up flask code
The flask code is located in the Flask folder. 

Filename: flas.py

```py
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```
Note: if you change the port, make sure to change it here too

## Running emotion detector server side
Run these commands in the terminal to setup emotion detection on the server side

### Setup ngrok server
you can use any port, but in this case 8080 is used
```terminal
ngrok http 8080
```
It should look like this
![alt text](image-1.png)
Everytime you run ngrok again, you have to grab the new url and put it in the homePageView.swift

In the example of the picture above: is the new url to be used

https://58db-23-117-48-87.ngrok.free.app

### Updating homePageView

Then you also have to update this line in homePageView.swift

```swift
struct homePageView: View {
    ...
    let backendURL = "https://a46d-2601-406-4d00-7af0-d964-735f-448-6a6a.ngrok-free.app/analyze"
    ...
```

Ensure you add /analyze to the end of the link, exactly as shown above

### Setup virtual env
#### Run this command in the flask folder to build the virtual env
```terminal
python3 -m venv deepface-env
```

#### Run this command in the flask folder to activate the virtual env
```terminal
source deepface-env/bin/activate
```

#### It should look like this
![alt text](image.png)

### Install these dependencies in order to run the flask code

```terminal
pip install flask
```

```terminal
pip install deepface
```

```terminal
pip install tf-keras
```

### Run flask code
```terminal
python3 flas.py
```

## After following all the steps, your terminal should look like this
Top terminal = ngrok http 8080
Bottom terminal = python3 flas.py
![alt text](image-2.png)

And finally, moodify utilize flas.py to process the emotion detection 