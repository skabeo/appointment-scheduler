##### by Chris Dritsas
# Appointment Scheduler

### Overview

This was a take-home interview project for a company. It was **timboxed to 4 hours**.
I have since extended it. 

* **Ask:**

     * _"Prototype a web application for scheduling an appointment"_

* **Input:**

   *  _"Given a [CSV dataset](./lib/tasks/coaches.csv) that contains the active coaches and their 
     weekly schedule of their available hours, Output the following
     User Stories:"_
         
* **Output:**
        
    * _As a User, I want to see which coaches I can schedule with._
    
    * _As a User, I want to see what 30 minute timeslots are available to schedule with a particular coach._
    
    * _As a User, I want to book an appointment with a coach at one of their available times._
               
* **Anit-Requirements:**

     * _You can't do it all. We respect your time, and expect that you will have to make 
        choices and tradeoffs for what is in scope for your deliverable._
     
     * _Don't worry about authentication. Assume a non-authenticated experience to keep things simple._
     
     * _Pick your stack. Choose any libraries that help you produce the highest quality work in the time available._
    
### Setup

* `bundle install`
* `bundle exec rails db:setup`
* `bundle exec rails import:all_data:from_csv`

### Run RSpec's

* `bundle exec rspec`
* `bundle exec rspec -f d --tag ~skip` (to skip pending tests)

### Run Rubcop

* `bundle exec rubocop`

### Run App

* `bundle exec rails s`
* `http://localhost:3000/`

### App Screenshots

* **Mobile Ready (Responsive)**

![alt text](./public/mobile-create-account.png "Responsive!")


* **Schedule a coaches time**

![alt text](./public/desktop-coach-time-slots.png "Responsive!")

---


