# Pictonnary

It's a indivudal project for learn flutter with firebase.

## Installation

Install dependences 

```bash
flutter pub get
```

## Firebase Setup

* Create a Firebase Project : Go to the Firebase Console and create a new project.
* Configure Authentication: In the Firebase console, enable email authentication under the "Authentication" tab.
* Configure Firebase Storage: Go to the "Storage" tab and set up rules as needed.
* Don't forget you must add rules => cloud firestore => rules => change this line and storage too

``` allow read, write: if request.auth != null;``` 

**This is the authorization rule you must be authenticated** 

* Run the project

```bash
flutter run
```

## Architecture

I try a simple architecture about my project:
- assets (contains all pictures)
- screens folder it's my pages
- widgets it's my logic i call widget on screens i try separated maximum my logic for readability

## Screen of my pictonnary

![Cover](https://github.com/Haroun-Azoulay/flutter_pictonnary/blob/main/img/db.png)
![Cover](https://github.com/Haroun-Azoulay/flutter_pictonnary/blob/main/img/authentication.png)
![Cover](https://github.com/Haroun-Azoulay/flutter_pictonnary/blob/main/img/rules.png)
![Cover](https://github.com/Haroun-Azoulay/flutter_pictonnary/blob/main/img/user_player.png)
![Cover](https://github.com/Haroun-Azoulay/flutter_pictonnary/blob/main/img/victory.png)

## Commentary

it's not perfect. I think I want to use thread for the timer because I have a small time lag between the drawer and the user. I have a little bug after winning because when I delete my room after the new party, all the players are drawers but it's my first project on mobile.


## Author

* **Haroun Azoulay** 
