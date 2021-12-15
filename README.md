# Welcome to DonkeyCar on balena!  

A [DonkeyCar](https://www.donkeycar.com) is a small autonomous vehicle project built on an RC Car chassis, that uses computer vision and machine learning techniques to convert the platform into a self-driving vehicle.  It uses a Raspberry Pi 3 or Jetson Nano, a camera, a motor driver, and of course the DonkeyCar application to perform this task.  There is also a "virtual" version that you can use to get started, prior to even building the physical version.  A "virtual" DonkeyCar looks rather like a video game, and it connects to a DonkeyCar Simulator just like the physical version, it can attempt to drive itself in the virtual world.

![](https://www.donkeycar.com/uploads/7/8/1/7/7817903/donkey-car-graphic_orig.jpg)

To cover these different scenarios there are 4 main Repositories for the project:

 - [DonkeyCar - Physical Build - Raspberry Pi](https://github.com/dtischler/balena-DonkeyCar-Physical)
 - [DonkeyCar - Physical Build - UpBoard](https://github.com/dtischler/balena-DonkeyCar-Physical-UpBoard)
 - [DonkeyCar - Virtual Build, Raspberry Pi](https://github.com/dtischler/balena-DonkeyCar-Virtual) 
 - [DonkeyCar Simulator - Intel NUC / x86](https://github.com/dtischler/balena-DonkeyCar-Simulator)

This Readme and Repo cover the **`Physical Build of a DonkeyCar using a Raspberry Pi 3 and RC Chassis`** version of the project.  You can refer to the other GitHub repos linked above, for other components or flavors of DonkeyCar.

Also note, the DonkeyCar project has their own [detailed documentation available](https://docs.donkeycar.com), that goes into more advanced topics and gives thorough descriptions of the architecture, machine learning and training scenarios, performance and tuning of models, and many more topics.  This Readme is simply intended to make it easy to get started, and once you have the core concepts down, be sure to refer to their documentation for more advanced guidance. 

## Intro

Waymo, Tesla, Cruise, and other companies already have self-driving vehicles deployed out in the world around us.  With this project, it is possible to build a miniature version of an autonomous vehicle, intended to race around a track, which is perfect for learning how the core concepts of computer vision and machine learning play a role in self-driving vehicles!

The physical construction of the DonkeyCar chassis requires about $250 USD worth of parts, with a Bill of Materials consisting of:

 - RC Car from this list:
	- Exceed Magnet Blue
	- Exceed Desert Monster Green
	- Exceed Short Course Truck Green, Red
	- Exceed Blaze Blue, Yellow, Wild Blue, Max Red
 - DonkeyCar conversion kit:
	[Mounting frame, motor driver, wires](https://store.donkeycar.com/)
 - Raspberry Pi 3
 - Raspberry Pi Camera
 - [Battery Pack](https://amzn.to/2AlMQJz)
 - SD Card
 - A track.  DonkeyCar is meant to race laps around a racetrack.

That is enough to build your DonkeyCar, and run the software that enables you to drive it.

However, let's also cover a few basics.  The car can be driven through a web browser, using the keyboard, a Bluetooth gamepad, or even via the accelerometer on your cell phone.  While driving, the DonkeyCar will record data about the car's throttle position, steering position, and what it "sees" in the camera.  When you are finished recording, all of the data is collected into a folder called a "Tub".  This metadata is then used as the input to create or "train" an AI model.  Once complete, the output of that process (the resulting *model* file) can then be used by the DonkeyCar to attempt to drive itself.  The Raspberry Pi loads the model, and attempts to navigate and move around the track on its own!

The process in the middle - the Training - takes a very long time on a Raspberry Pi.  Analyzing all of the data that got recorded during driving, creating a neural network, and iterating on that data over and over through what are called epochs can easily take hours on the Pi.  And once complete, there is no guarantee the DonkeyCar will even be able to drive safely and accurately!  So, to improve that feedback loop and to reduce the iteration time, most people find it better to drive the DonkeyCar and collect the data, but then transfer that resulting "Tub" of data to a cloud server or a PC with a GPU, and perform the training there.  Once it completes (hopefully much quicker!), the resulting output of the process is the *model* file just like mentioned above, and that model can be transferred back to the Pi.  Then, the DonkeyCar can try to drive using it (hopefully it drives good!).


## Build

We are not going to cover the physical construction of the DonkeyCar in this Readme, because that is [covered in detail in their Documentation](https://docs.donkeycar.com/guide/build_hardware/).  The basic premise however, is that you will remove the plastic car body from the RC Car chassis, and replace it with the DonkeyCar frame.  Place the Raspberry Pi on the frame, the motor driver on the frame, and the Pi Camera in the holder slot near the top of the handle.  Run the jumper wires from the Pi to the motor relay board.  Connect the camera via it's ribbon cable.  Secure everything in place with included screws, and the DonkeyCar is complete!

Again, for a proper and thorough walkthrough of the build, refer to the DonkeyCar documentation or their build video here:  https://www.youtube.com/watch?v=OaVqWiR2rS0

Here is where we vary from their Documentation and begin to "balenafy" the project:

 - In the official DonkeyCar workflow, they begin to walk you through installation of Raspbian, installation of added software and packages such as Tensorflow, PyTorch, OpenCV, Keras, and the rest of the bits necessary for the machine learning functionality.  Then, they have the user install Python and the DonkeyCar application.  At the end of the process, if everything worked, the web interface should load and the car can be driven remotely.
 - However, in this repo, we have bundled all of those bits into a Dockerfile, and instead of performing all of those manual installation steps, you can instead just click this button to launch a build in the cloud, provision a balena device, download an SD Card image, and end up with the same result:

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/dtischler/balena-DonkeyCar-Physical)

More specifically:
1. Click on the Blue Button just above.
2. Log in to balenaCloud, or create an account if you do not already have one.  (It is free :-) )
3. Create a name for the application in the pop-up modal, and choose the RaspberryPi 3 from the drop down list.
4. Click Create and deploy.
5. Click Add Device.
6. You will come to the Summary page.  Here, click "Add Device".
7. While developing, it is probably best to choose a Development variant of the operating system, and you can enter your WiFi credentials as well.
8. At the bottom of the modal, click "Download balenaOS".
9. After download completes, flash the file to your SD Card with Etcher.
10. Insert the SD Card into the Raspberry Pi, plug into your USB Battery pack, and wait a few minutes for it to register itself with balenaCloud and come online.
11. After another moment, the Pi will begin downloading the pre-built DonkeyCar container, which will take some time.  Get a cup of tea while this occurs.

Once the Pi has finished downloading the container, we have two quick settings we need to add in the balenaCloud dashboard.  After each entry, the Pi will reboot, so after you get the first entry in, it will take a moment before you enter the second variable we need to alter.  So, you'll just have to watch closely, but not a big deal.

First, click on Device Configuration on the left in the balenaCloud dashboard, and look for "Define device GPU memory in megabytes".  It is likely set to `16`.  Click on the pencil icon to edit it, and change the value to `128`.  Click "Save".  This is going to trigger the first reboot.  Click on Summary on the left navigation, and watch for a moment as the device shuts down, then in a moment comes back online.  Once it is back "Online", we can enter the second setting.  Click on Device Configuration again, and this time scroll down to "Custom Configuration Variable" section.  Click the blue "Add Custom Variable" button.  In the name, enter `BALENA_HOST_CONFIG_start_x` and in the value, just enter a `1`.  Click Save.  This will again trigger a reboot. 

We're ready to drive now, so, it is time to move on to the next section!


## Drive
 
With your DonkeyCar fully constructed, and the container downloaded and running, it's time to test out a few basics before you go for your first drive.

First and foremost, put your DonkeyCar up on blocks so the wheels are off the ground.  These cars are **FAST**, and the first time I attempted to drive, I ran into a wall so hard I snapped an axle and had to order spare parts to repair it :-(

With the cars wheels lifted, connect the vehicle battery pack if it is not already, and turn on the ESC switch.  The car is now live, so be careful!

Next, in balenaCloud, on the Device Details page, open up an SSH session to the DonkeyCar container with the Terminal interface at the bottom right portion of the screen:

![](/images/img1.png)

Type in `cd mycar && python3 manage.py drive` and press Enter. The script will launch, and take a moment to complete, but will eventually reach `Starting vehicle at 20 Hz`

![](/images/img2.png)

Check the IP address of your Raspberry Pi in the balenaCloud dashboard.  Make note of this IP.  Open a web browser, and go to `http://ip-address-of-your-pi/drive`.  In my example, this would be `http://192.168.0.232/drive`.

![](/images/img3.png)

Now, double check that the DonkeyCar is secure, well-balanced, and those wheels are off the ground.  In the throttle and steering applet on that page, click and drag just a tiny bit up from center, and your wheels should start spinning!  You can click and drag a bit left, and the steering should match.  If not, you'll want to double check your wiring, check the logs in the balenaCloud dashboard for any errors, and make sure everything has power.  If everything works as expected, congratulations, the DonkeyCar is ready to drive.

As mentioned earlier, the official DonkeyCar documentation is more detailed, so you can refer to those Docs for more detailed usage.  But keep in mind these important details:

- DonkeyCar is meant to be used on a racetrack, so, you can construct a course using tape, blocks, paint, cups, cones, or any other materials that allow you to make a small course.
- Don't let DonkeyCar venture out of range of WiFi, or you'll lose connectivity to it.
- Using the web portal for driving (use a Bluetooth controller for a much better experience than driving via keyboard or phone), drive a few practice laps around your track.  When you have a good feel for driving and are ready to capture data, click the "Start Recording" button, and at this point DonkeyCar will begin storing the throttle, steering, and camera feed for later use in the Training process.
- Drive at least 10 laps around your track, preferably more, while Recording.
- Once you have completeled 10 laps (or more), you can stop the Recording.
- Over in the balenaCloud Dashboard, in that Terminal window, press `Control-C` on the keyboard to exit out of the DonkeyCar application.
- You will see all of the data get written out in a table, and the raw files are stored in the `data` directory inside of that `mycar` folder.

![](/images/img4.png)

  
## Train

Now that we have a bit of sample data recorded and saved, it's time to begin training our model.  Remember, as mentioned above, it is **NOT** very efficient to train directly on the Raspberry Pi, and using a cloud server or a desktop PC with a GPU will be MUCH faster.  However, simply for learning purposes and to keep things organized and in one place, we will in this situation train directly on the Pi.  It could literally take 8 to 10 hours or more, so, grab a cup of tea, and sip it VERY slowly.  Or do something else in the meantime.

Back in the terminal session in balenaCloud, and still within the DonkeyCar container, run `donkey train --tub ./data --model ./models/myawesomepilot.h5`. Now go do something else.

![](/images/img5.png)

Fast forward 10 or so hours, and returning to balenaCloud, you should see that process has completed.  The output of all that hard work is the model file.  Double check that everything completed successfully, and you should have a file sitting in the `models` directory called `myawesomepilot.h5`

![](/images/img6.png)

### Speeding Up Training

Knowing full well that training on the Pi is not ideal, we simply want to demonstrate functionality in this GitHub repo.  If you are interested in offloading the Tub data and training on a PC or Cloud server, have a look at the official DonkeyCar docs here: [https://docs.donkeycar.com/guide/train_autopilot/#transfer-data-from-your-car-to-your-computer](https://docs.donkeycar.com/guide/train_autopilot/#transfer-data-from-your-car-to-your-computer).  That will help immensely.  :-)


## Drive Autonomously

With the model now ready (hope you slept well), you can try to let the DonkeyCar now navigate your racetrack autonously.  Fair warning, mine did not drive very well with only 10 laps of data, so, be ready to grab it quickly if it starts heading for a wall!

- Place the DonkeyCar on your track.
- Turn on the ESC switch, which sets the car live.
- In balenaCloud dashboard, open up a terminal session to the DonkeyCar container.
- Enter `python manage.py drive --model ~/mycar/models/myawesomepilot.h5`
- Navigate to `http://ip-address-of-your-pi/drive` once again.
- Get ready, the vehicle is about to launch!  On the left, click the dropdown menu for `Mode and Pilot`, and choose `Local Pilot`.
- The DonkeyCar should begin to make it's way around your track.
- Be ready to grab it in case of emergency!

![](/images/img7.png)

## Conclusions

This repo is intended to demonstrate the containerization of DonkeyCar, and help you to quickly deploy the software stack that they are gracious enough to build and maintain.  Taking a high-level perspective, you have literally built and trained an autonomous vehicle, and have a miniature self-driving vehicle.  The training process on the Raspberry Pi is not ideal, but there are methods to help accelerate the process by offloading the data.  And if you are not quite ready for thie physical build, you can always build a Virtual DonkeyCar, and compete in the online races the community hosts: [https://www.meetup.com/DIYRobocars/](https://www.meetup.com/DIYRobocars/)
