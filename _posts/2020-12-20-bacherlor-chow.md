---
layout: post
title: "Bachelor Chow: A Recipe a Day"
---

One thing that has annoyed me for quite awhile was that when you look for recipes online there is alot of extra fluff. There seems to be some sort of story before the recipe and intrusive Ads. So I thought that I would make a webpage that will display a recipe without all the extra junk. One other problem is when looking for a recipe there is so many that its easy to just surf recipes and not make a decision so my solution will limit that by only providing one recipe a day. A user can go to the page and decide if they want to cook it or not, then get on with their day.

So I started to build what I called [Bachelor Chow](https://bachelorchow.net). The bit from Futurama has always stuck with me and I thought it would be cool. So I thought that I would write a article on the process that I used to create this app. On the outset I didn't know anything about modern web development, I know the basics of python but I am not a expert. So join me in the process to create an app while learning new skills along the way.

## Getting started

The next task was to find a recipe database of some sort. It was difficult to find one that I could use without having to pay for one. Eventually I found a [repository](https://github.com/tabatkins/recipe-db) on github that was just a json file with a bunch of recipes. That will do.

I cloned the recipe repository and copied the json file into my project. Now to just start on the python program. I using my power of google and past experience I wrote a small program that would open the json file, load the json in to a python object using the json python module and printing out the first json object. Success! Nothing like that little dopamine hit when something works. Now I won't go into every little programming detail, but I'll try to describe milestone along the journey. Next I got it picking a random recipe, updating it every minute outputting the recipe to a file in a html table.

## Hey I know lets create micro-services

Micro-services are all the rage these days, and everywhere you look it's Docker this and Docker that. This is something that fits this project, one Docker container that will pick the recipe, and output it in a html format that another container use to display. Well I guess it time to start learning about Docker.

To learn Docker I used Udemy and I happened to be in luck. A Docker class was on sale for 15 dollars. Then I started watching and working along in the class until I understood enough to get a docker file created that installed python and my script. I continued iterating on the container adding a command that would automatically start the python script, bind mounting a directory to the container, getting the Nginx container to display the html table and finally a docker-compose file that would start my two containers. Easy Peezy it was all done just like that in one afternoon. HAH! Lies! Those two sentences were a lot of work, I was working on this in my spare time so I had to go back to the class and re-watch, re-fresh what I had learned and experiment. We have a program that is running micro-services! Oh yeah gimmie another dopamine hit.

![tablerecipe.png](/images/bachelorchow_assets/tablerecipe.png)


## Life happens and development stops

Work gets busy and I lose interest due to the long workdays. It pretty much does 90% of what I want it too anyway and I have proven to myself that I can do it. The project slumbers until, BOOM covid-19 and layoffs hooray! I think that I am going to lay around a play video games for a couple of weeks, Dark Souls 3 here I come!

![YouDied.jpeg](/images/bachelorchow_assets/YouDied.jpeg)


Ok fine I guess I should find a job, guess I have to do some leetcode problems. These questions just don't do it for me. I take your array of data and transform it in some way, but no dopamine bump, awfully boring. Oh, there was that recipe thing I was working on but I probably should do leetcode so that I can get a job.

## Screw leetcode and lets serve up some recipes

I don't really like the recipe "database" that I am using. There are a lot of inconsistencies in the recipes formatting in the json file. Lets try to find a recipe database again. After more searching I managed to find a website called [RapidAPI](https://rapidapi.com/). This site has a collection Rest API's that developers can use and there is one called Spoontacular that has a API for a random recipe and as long as I do not get more than 50 per day it's free! 

## From now on lets try Test Driven Development (TDD)

Test Driven Development is a development process where you write unit tests before you create the product code. It flips development on its head from the way that you have learned it in school and most likely 99% of the places that you have worked. I have attempted this with varying degrees of success in the past, I have come to the conclusion that you write the tests in parallel rather than first. At least not complete tests. I wrote test skeletons where its just the test name and the call to the function that will implement the functionality. I came up with the following tests that will be using pytest.

```
def test_get_random_recipe()

def test_get_api_key()
    
def test_get_prefetched_recipe()

def test_get_recipes()

def test_get_ingredients_not_empty()

def test_verify_ingredients()
```

I then defined the functions that will have the actual functionality.

```
def get_api_key(secretFile="test/test_secret")

def get_pre_fetched_recipe()

def get_random_recipe()

def get_recipe_ingredient_names()
```
Writing the tests first will make you think about how you are going to test the functions. If I had not thought about the tests the function test_get_prefetched_recipe probably would not exist. Because I would have just looked at the output of get_recipe_ingredient_names and manually compared. But if you need to programmaticly verify the ingredients they cannot change every time. I had to program the functions in a way that it would return the same recipe each time. So the test can verify the ingredients are getting pulled out of the recipe properly. This also caused get_random_recipe to be instrumented so that it could return a expected recipe in for testing.

## Continue to iterate gradually building up the recipe service

From here I have a pretty good base to work on. Right now all of the recipe functionality is in a single file with functionality to get the recipe and to parse out the recipe elements. I think this should be split up, there should be a class that will provide a interface to get all of the recipe elements. Since I have unit tests that verify functionality it was not much work to create a SpoontacularRecipe class, move the recipe element functions into the new class and update the unit tests to use the SpoontacularRecipe class. Because the unit tests were already implemented, when I ran the tests and they passed I was confident that I didn't break anything.

I then worked on writing tests and implementing the other recipe functions that I needed until I had the functionality implemented to get all of the different recipe elements that I wanted which at this time was only the recipe title, the recipe ingredients and the recipe instructions.

![test_dev_50.png](/images/bachelorchow_assets/test_dev_50.png)

## Unit tests that verify error conditions

While I was writing unit tests I did write some that would verify that the functions would not crash if the recipe was missing a critical element. If it was the program would retry and get a new recipe. Now I had not seen this happen before when getting the recipe from Spoontacular, but eventually Spoontacular did return a recipe that was missing instructions. The cool thing was the program handled this error condition without issue. That was the first time this had happened to me and it was cool to see. As a developer you need to decide how much you are going to trust the output of third party components that you do not have control over.

## Building a webpage
I do not know anything about making a webpage. The last time I attempted to make one it was probably the year 2000. I envision a simple webpage with just the recipe. I think by now this should be pretty standard and easy to do. I have heard about Wordpress but from an initial investigation I wasn't sure if it would work with my program. That's when I stumbled across [Jekyll](https://jekyllrb.com/). It is a program that will automatically generate a static webpage. It sounds like it will work wonderfully for what I need.

Upon more investigation it required Ruby. Ugh what is that? You know what this sounds like, yep another container. I decide to take a look at [dockerhub](https://hub.docker.com/), and lucky me there is a Jekyll container.

At this point I had to learn about how to use Jekyll. I Created a separate project and went through the tutorial that they had and created a simple blog. This did take a couple of days to get up to speed and learn the basics of web page creating and Jekyll. This works by creating a template webpage, and then inserting the content that changes into the template.

But that is not enough to make a good looking webpage. So I checked out udemy again and bought a web developer bootcamp class that was on sale for 16 bucks. I watched the lessons on html and css. I think that is all that I will need for this project, javascript will have to wait for another day.

After a week or two of taking the class I had a pretty good looking template webpage that Jekyll will use and insert the recipe that is generated into. I also had to re-work the recipe generator script to output the recipe in html format. This was done with a bunch of writes to a file that Jekyll will use. I could have probably used Flask here but I do not know it and the recipe is pretty simple so brute force writes will work. This would be an area of improvement in the future. If I have done my unit tests correctly it should be pretty easy to refactor without breaking anything.

## Getting everything to work together

Now I have 3 containers, a bachelor chow container that gets and generates the recipe in html format to a file, a Jekyll container that will use the generated html recipe and create a entire static webpage and a Nginx container that will serve the webpage. All of these containers need to share a volume. I opted to creating a docker volume rather than bind mount a volume to each of them. This should reduce the dependency on the underlying platform. But this will also make it a bit more difficult to debug things as I will need to either sudo to the docker generated directory on the host or connect to a container and access it that way. There are probably other ways to do this but I have not looked those up yet. 
Now that we have multiple containers and they are all dependent on a docker volume I decided to use docker-compose to bring up all the containers and define dependencies. It was getting rather annoying typing all of those docker commands by hand. I already had some docker-compose knowledge but I still went back to my Udemy docker class and reviewed those.

## We have a Minimal Viable Product (MVP)

Congratulations I think what we have here is a Minimal Viable Product or MVP for short. Since I am creating this I get to define it, normally you would get this from a product owner in a corporate setting. I have an app that when brought up that will get a random recipe, generate the recipe in html, Jekyll will detect the new recipe and generate the entire webpage and save it, and then Nginx will serve it up.

## Sharing with the world

Next is learning about domain names and hosting. I shopped around and ended up buying bachelorchow.net from google domains. Next is hosting, I had had used digital ocean in the past for something, I don't remember what. But I knew I could get a Linux vm from them. So I got the introductory trial and spun up a Linux vm. Followed some tutorials to make it more secure. Then I deployed my app to the host and brought it up. Low and behold! I could go to my website and see a recipe! That was satisfying to see, dopamine bump.

I wanted the possibility of it being able to support itself. I have heard of buy me a coffee, so I did my research on those donation sites. Ultimately I went with ko-fi. I had to create a account with them, create an account with PayPal and put a link on my webpage. I did get the initial donation from my father but that is it. I didn't think that I would really get anything anyway. Since I did have a link to a payment processor I wanted to make sure everything was as secure as possible so I wanted https to be enabled.

So I added yet another container, and it was shockingly easy. I had found a tutorial for a container called Traefik that would handle https. All I had to do was add another entry for Traefik to my docker-compose file and add some options to the Nginx definition and abracadabra I had https.

![container_diagram.png](/images/bachelorchow_assets/container_diagram.png)

## Conclusion

I hope this article gives you a better idea of how software is developed from beginning to end. This is how I did it, its not the only way or the correct way. I illustrated that really there is little actual programming that you have to do. The bulk of it is getting different software to work together and with the usage of containers that is getting easier. There are plenty of things to do to improve this. Such as refactoring some of the code I wrote, adding more tests, adding more features like a print button and adding some system testing. The system testing manual and not automated to make sure that all of the docker containers are working together. Right now its not bad, just bring up the app and make sure the webpage is displayed. All of that would be another iteration of the development cycle.
