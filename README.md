# Gecko URL Shortener
[![Run Tests](https://github.com/ryancyq/gecko-url-shortener/actions/workflows/test.yml/badge.svg)](https://github.com/ryancyq/gecko-url-shortener/actions/workflows/test.yml)
[![Deploy fly](https://github.com/ryancyq/gecko-url-shortener/actions/workflows/deploy.yml/badge.svg)](https://github.com/ryancyq/gecko-url-shortener/actions/workflows/deploy.yml)

## Overview
A URL Shortener service that maps a short-form URL to a user-provided URL.

### Short form URL generation
For a short-form URL with a 15-character limit on the URI path, this means we have a space of 
C^15 (where C is the number of URL-safe characters).

In general, standard URL-safe characters include numeric digits (0-9) and case-sensitive letters (a-z and A-Z). This adds up to a total of 62 characters available for short-form URL generation.

`62 = 10 (digits) + 26 (a-z) + 26 (A-Z)`

Given the 15 characters, there are two ways we can utilize them:

1. Character Decoding Approach
  By considering each character from the 62-character set, decoding the 15 characters gives us an integer in the range of 1 to 62^15. This allows us to map the number space to the object ID space of short-form URLs. Therefore, 15 characters give us a maximum of 62^15 ~= 7 * 10^26 unique short-form URLs.

2. Bit Conversion Approach
  By considering each character from the 62-character set (similar to Approach 1), we can take the decoded integer, convert it into bits, and reconstruct it back into characters using 8 bits per character instead of 6 bits.

  `log2(62^15) / 8` gives us around 11 characters, which we can apply to the object ID space of short-form URLs. This provides us with a maximum of 10^11 unique short-form URLs.

#### Comparision
Approach 1 seems better than Approach 2; however, it has drawbacks in the URI path randomness. For example, a short-form URL with id=1 would generate the URI path "/1", id=63 would give "/11", and id=3907 would give "/111". Even if we shuffle the order of characters in the 62-character set, a predictable pattern in the URI path still exists.

On the other hand, Approach 2 takes an object ID, converts it into characters and then into an integer, and encodes it using the 62-character set. For example, id=1 gives "/4NhuQh0in8WwpPi", id=63 gives "/4ZvHPgJ4uGIquiI", and id=64 gives "/5nxPthEABhitIBO".

Although Approach 2 only provides 10^11 unique short-form URLs, it is actually sufficient for most systems. Considering a scenario with 50req/seconds for short-form URL creation, 50 * 3600 seconds/hour * 24 hours/day * 365 days/year ~= 3 x 10^9. This means the 10^11 space can technically serve the system for ~ 63 years.

### Clickstream Data

To understand the usage of each short-form URL, additional parameters are collected for analytical purposes.

When a user enters the short-form URL in a browser, the following data is captured during the URL redirection:
- IP Address (to understand the demographics of users)
- User Agent (to differentiate normal users from API/Bot users)

After the URL redirection is completed, the system will fire a background job to post-process the IP Address.
This is done with calling the API from [ipinfo.io](https://ipinfo.io) via [Geocoder](https://github.com/alexreisner/geocoder?tab=readme-ov-file#geocoder) gem.

### Web Interface
- Visit `/url` to start using the service.
- Enter a URL, e.g. `https://www.ruby-lang.org`.
- Click on `Shorten URL`.
- Upon successful creation, the following information will be shown:
  - The provided URL
  - The page title of the provided URL
  - The generated short-form URL
- Copy the short-form URL and paste it into your browser to be redirected to the target URL.

### Admin Interface
- Visit `/admin` to access information about URLs being shortened.
- Look for a target URL of interest.
- Click on `Shorten URLs v`
- A list of short-form URLs with the same target URL will be displayed in order of creation date.
  - The latest usage of the short-form URL will be displayed
    - `last visited`
    - `no clicks yet / X times`
- To dive further into the short-form URL usage, click on `Show Details`
  - A table of all the click events for the given short-form URL is shown
    - **User Agent** refers to the client's software when accessing the short-form URL
    - **Country** & **City** are populated base on the **IP Address** provided by [ipinfo.io](https://ipinfo.io)

### API Interface
- **target_urls** (reference of user provided URLs)
- **short_urls** (reference of short-form URLs for a user provided URL)

Note: for technical specifications, see [RESTful Endpoints](#api-endpoints)

### System Dependencies

- `ruby` 3.2.2
- `rbenv` 
- `sqlite3` (download from [sqlite3 official site](https://www.sqlite.org/download.html))

### Libaries used
- [Rails](https://guides.rubyonrails.org/getting_started.html)
- [Turbo](https://github.com/hotwired/turbo-rails?tab=readme-ov-file#-turbo) (JavaScript framework for page rendering)
- [Stimulus](https://github.com/hotwired/stimulus?tab=readme-ov-file#-stimulus) (JavaScript framework client side interaction)
- [jbuilder](https://github.com/rails/jbuilder?tab=readme-ov-file#jbuilder) (JSON serializer)
- [FFaker](https://github.com/ffaker/ffaker?tab=readme-ov-file#ffaker) (Test data generator)
- [Factory Bot](https://github.com/thoughtbot/factory_bot_rails?tab=readme-ov-file) (Test fixture replacement)
- [RSpec](https://github.com/rspec/rspec-rails?tab=readme-ov-file#rspec-rails--) (BDD Testing framework)
- [VCR](https://github.com/vcr/vcr?tab=readme-ov-file#vcr) (HTTP request recorder for tests)
- [Capybara](https://github.com/teamcapybara/capybara?tab=readme-ov-file#capybara) (Acceptance Testing framework)
- [Geocoder](https://github.com/alexreisner/geocoder?tab=readme-ov-file#geocoder) (Geolocation API to [ipinfo.io](https://ipinfo.io))
- [Tailwindcss](https://github.com/rails/tailwindcss-rails?tab=readme-ov-file#tailwind-css-for-rails) (CSS framework)

### Installation
- Install `rbenv` package manager for `ruby` dependency. (see [rbenv guide](https://github.com/rbenv/rbenv?tab=readme-ov-file#installation))
- Install project dependency
  ```
  bundle install
  ```
- Initialize database
  ```
  bin/rails db:migrate
  ```
- Run the server
  ```
  bin/rails server
  ```
- Visit the site at [http://localhost:3000](http://localhost:3000)

### Development

#### Working on backend

- Run `bin/rails server` to start the server 
- Run `bin/rails console` to troubleshoot your code in the application environment
- Run tests (include system tests)
  ```
  bundle exec rspec
  ```
  or
  ```
  bundle exec rspec --exclude-pattern "**/system/**/*_spec.rb"
  ```
  to exclude system tests

#### Working on frontend

- Run `bin/dev` to start the 2 processes
  - `bin/rails server` the usual server
  - `bin/rails tailwindcss:watch` live rebuilds on the css assets
- Run browser/system tests
  - `bundle exec rspec **/system/**/*_spec.rb`

### API Endpoints

#### Target Url
`GET /api/target_urls/` to retrieve all target urls:
- response body:
  ```json
  [
    {
      "id": 1,
      "url": "https://v1.tailwindcss.com/components/alerts",
      "title": "Alerts - Tailwind CSS",
      "created_at": "2024-06-03T16:08:51.470Z",
      "shorten_urls": [
        {
          "id": 3,
          "url": "http://localhost:3000/4NhuQh0in8WwpPi",
          "created_at": "2024-06-03T16:08:51.478Z"
        },
        {
          "id": 8,
          "url": "http://localhost:3000/5tAuw2DzIdvxGYU",
          "created_at": "2024-06-04T17:04:05.770Z"
        }
      ]
    },
    {
      "id": 2,
      "url": "https://www.rubyguides.com/2019/11/rails-flash-messages/",
      "title": "How to Use Flash Messages in Rails - RubyGuides",
      "created_at": "2024-06-03T16:10:28.604Z",
      "shorten_urls": [
        {
          "id": 2,
          "url": "http://localhost:3000/4Tkd565Uhis61HO",
          "created_at": "2024-06-03T16:10:28.613Z"
        }
      ]
    },
  ]
  ```
`GET /api/target_urls/:id` to retrieve a single target url:
- response body:
  ```json
  {
    "id": 5,
    "url": "https://google.com/%20",
    "title": null,
    "created_at": "2024-06-03T17:10:46.291Z",
    "shorten_urls": [
      {
        "id": 5,
        "url": "http://localhost:3000/5bslNzmJZKYORlm",
        "created_at": "2024-06-03T17:10:46.300Z"
      }
    ]
  }
  ```
`POST /api/target_urls` to create a target url:
- request body:
  ```json
  {
    "url": "http://www.google.com"
  }
  ```
- response body:
  ```json
  {
    "id": 5,
    "url": "https://google.com/%20",
    "title": null,
    "created_at": "2024-06-03T17:10:46.291Z",
    "shorten_urls": [
      {
        "id": 5,
        "url": "http://localhost:3000/5bslNzmJZKYORlm",
        "created_at": "2024-06-03T17:10:46.300Z"
      }
    ]
  }
  ```

`DELETE /api/target_urls/:id` to delete a target url and related short urls.

#### Short Url
`GET /api/target_urls/:target_url_id/short_urls` to retrieve all short urls:
- response body:
  ```json
  [
    {
      "id": 7,
      "url": "http://localhost:3000/5nxMhdxXO3ZY56o",
      "created_at": "2024-06-04T15:09:31.196Z"
    },
    {
      "id": 13,
      "url": "http://localhost:3000/4Zoo4tM6TZq872o",
      "created_at": "2024-06-06T17:35:22.143Z"
    }
  ]
  ```
`GET /api/target_urls/:target_url_id/short_urls/:id` to retrieve a single short url:
- response body:
  ```json
  {
    "id": 13,
    "url": "http://localhost:3000/4Zoo4tM6TZq872o",
    "created_at": "2024-06-06T17:35:22.143Z"
  }
  ```
`POST /api/target_urls/:target_url_id/short_urls` to create a short url:
- response body:
  ```json
  {
    "id": 14,
    "url": "http://localhost:3000/55r6jiRIO8VHIUU",
    "created_at": "2024-06-06T17:37:16.480Z"
  }
  ```

`DELETE /api/target_urls/:target_id/short_urls/:id` to delete a short url.