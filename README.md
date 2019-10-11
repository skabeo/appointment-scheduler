##### by Chris Dritsas
# Appointment Scheduler

### Overview

This is a take-home, interview project from a company that was **timboxed to 4 hours**.
I have since extended it a bit by updating with code clean up and adding clairity it. 

* Ask:

        "Prototype a web application for scheduling an appointment"

* Input:

        "Given a CSV dataset that contains the active coaches and their 
         weekly schedule of their available hours, Output the following
         User Stories:"
         
* Output:
        
         1. As a User, I want to see which coaches I can schedule with.
         2. As a User, I want to see what 30 minute timeslots are available to schedule with a particular coach.
         3. As a User, I want to book an appointment with a coach at one of their available times.
                   
* Anit-Requirements:

         1. You can't do it all. We respect your time, and expect that you will have to make 
            choices and tradeoffs for what is in scope for your deliverable.
         2. Don't worry about authentication. Assume a non-authenticated experience to keep things simple.
         3. Pick your stack. Choose any libraries that help you produce the highest quality work in the time available.
        
### Setup

* `bundle install`
* `bundle exec rails db:setup`
* `bundle exec rails import:all_data:from_csv`

### Run RSpec's

* `bundle exec rspec`

### Run App

* `bundle exec rails s`
* `http://localhost:3000/`

### Screenshots

* **Mobile Ready (Responsive)**

![alt text](./public/mobile-create-account.png "Responsive!")


* **Schedule a coaches time**

![alt text](./public/desktop-coach-time-slots.png "Responsive!")

---


