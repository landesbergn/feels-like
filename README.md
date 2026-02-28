# Feels Like (for iOS) - End of Life
I worked on this project while living in Cambridge, Massachusetts in the early winter of 2018. I found myself frustrated that the temperature was constantly misrepresented by weather apps and wanted to build something that felt more honest. 

On December 30th, 2018 Apple unceremoniously rejected my application from the App Store, stating:
> We found that the usefulness of your app is limited by the minimal amount of content or features it includes. 

Clearly Apple was threatened by this project, and just a few years later purchased DarkSky and shut down the API that powered this app.

During this project I learned about:
* iOS and Swift development, and the value of YouTube tutorials for building software
* How to calculate wind chill / heat index, and convert between F and C
* The tyranny of gatekeepers keeping revolutionary weather technology from the masses

This project is no longer being maintained, and the original README follows below.

<hr>

:snowflake::snowman: who cares that it's 20° when it **FEELS LIKE** -5°! :snowflake::snowman:  
:sunny::sun_with_face: who cares that it's 87° when it **FEELS LIKE** 102°! :sunny::sun_with_face:   

<hr>

Introducing **Feels Like**:  
:sparkles:The first and only weather app for iOS that EXCLUSIVELY tells you the what the temperature *feels like*:sparkles:
<hr>

### Instructions to build in Xcode
Thanks for your interest in working on Feels Like! If you would like to see how Feels Like works or contribute directly, feel free to [clone the repository](https://help.github.com/articles/cloning-a-repository/) or [create a pull request](https://help.github.com/articles/creating-a-pull-request/).

#### :one: - Get an API Key
The first thing you will need to do register with Dark Sky and get a your own private API key.
* You can register here: https://darksky.net/dev/register
* Once you have registered, you should be able to see your API key here: https://darksky.net/dev/account

 **Important: Keep this key private!**
 
#### :two: - Put your API key in a Property List  
In the Feels Like directory, you will need to make a property list file with your API key.
* Open `Feels Like.xcworkspace` in Xcode
* `File` --> `New` --> `File...`
* Select `Property List`
* Press `Next`
* Name the file `keys`
* Make sure the file is created in the `Feels Like` directory
* Press `Create`
* Open `keys.plist` in Xcode
* Press the :heavy_plus_sign: button to add a new item
  * Key: `darkSkyKey`
  * Type: `String`
  * Value: `YOUR_API_KEY`
  
#### :three: - Build and run! 
If you run into issues, let me know.
