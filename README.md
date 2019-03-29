# Achiever


A rails plugin to add an achievements system to your app.  Features
include icon management, several achievement types, and default views that make
it super easy to integrate into an existing project.

## Table of Contents

- [Install](#install)
- [Setup](#setup)
  * [Setup Files](#setup-files)
  * [Setup a Subject](#setup-a-subject)
  * [Setup Views](#setup-views)
    + [Achievements Page](#achievements-page)
    + [New Badges Notification](new-badges-notification)
    + [Note](#note)
- [Usage](#usage)
- [Slotted Achievements](#slotted_achievements)

## Install

Add the gem to your Gemfile.

```ruby
gem 'achiever'
```

Run `bundle install`

Run `bin/rails achiever:install:migrations` to install the required migrations

Run `bin/rails db:migrate`

## Setup

### Setup Files

Two files are required for achiever to function properly.
`config/achiever.yml` and `config/locales/achievements.yml`

**Note** that the path `config/achiever.yml` can be configured using
`Achiever.file=`, and `config/locales/achivements.yml` is merely a
recommendation.

The file `config/achiever.yml` contains your achievements and some configuration
options.  An example is below:

```yml
config:
  defaults:
    achievement:
      visibility: hidden
achievements:
  logins:
    badges:
      - required: 1
        img: logins_1
      - required: 10
        img: logins_10
```

There are two sections, `config` and `achievements` with the former being
optional.  `achievements` is a hash where the keys are achievement names and the
values contain that achievements configuration in another hash.  The only
required key of an achievement hash is `badges` which points to an array of
hashes, each detailing information on a particular badge.  The only required key
of a badge is `required` which contains the requirements that badge has before
it is achieved.

For more info see documentation on `lib/achiever/config_validator.rb`.

The locale file contains all the strings related to your badges.  A companion to
the above config would be:

```yaml
en:
  achiever:
    achievements:
      logins:
        badges:
          - name: Hello World!
          - name: Veteran
        desc:
          one: Login once
          other: Login %{count} times
```

Notice that everything is namespaced under the `achiever` key to avoid
collisions.  Additionally any badge may have a `desc` key that will be used, if
it exists, in place of the achievement's description.  This translation will not
be passed a `count`.

The order of the badges in the above two files is important per achievement.  It
controls the order that badges are displayed on the achievements page.  If you
change the order in one file don't forget to change the order in another or the
names and possibly descriptions will be incorrect.  If the number of badges in
the locale file does not equal the number of badges in the config file, there
will probably be undefined behaviour.

### Setup a Subject

A "subject" is something that can achieve, i.e. it `has_many :achievements`.
You can make any of your models a subject by including `Achiever::Subject`.

```ruby
class User < ApplicationRecord
  include Achiever::Subject
end
```

### Setup Views

#### Achievements Page

If you want the included achievements page, mount the engine like this in
`config/routes.rb`

```ruby
mount Achiever::Engine, at: '/achievements'
```

Additionally, you must specify the `achiever_subject` in your
`ApplicationController` to that the achievements page knows what has
achievements.  You can use the helper method `achiever_subject=` by including
`Achiever::AchieverHelper`.

```ruby
class ApplicationController < ActionController::Base
  include Achiever::AchieverHelper
  before_action :set_achiever_subject

  def set_achiever_subject
    self.achiever_subject = current_user if current_user
  end
end
```

This will make `/achievements` route to a page that displays all the subject's
achievements.

#### New Badges Notification

If you want notifications when new badges are displayed, you can render the
`achiever/new_badges` partial.  Note that you must pass the partial a `subject`
so it knows what to check for new badges.

Example in `app/views/layouts/application.html.erb`

```erb
<% if user_signed_in? && current_user.has_new_badges? %>
  <%= render 'achiever/new_badges', subject: current_user %>
<% end %>
```

#### Note

The achievements page will render within your applications layout so you must
proxy all route helper methods with `main_app` in order to avoid conflicts.

This means that if you have a layout that includes something like:

```erb
<%= link_to "home", root_path %>
```

You need to change it to

```erb
<%= link_to "home", main_app.root_path %>
```

reference: https://guides.rubyonrails.org/engines.html#routes

## Usage

In order for your subjects to achieve things, you need to call `#achieve` on
them.  The first parameter of `#achieve` is the name of the achievement, defined
in `config/achievements.yml` and the second is how much you want the subject to
progress.

For instance, if we wanted to implement the `logins` achievement, we would need
to run the following every time a user logged in.

`current_user.achieve(:logins, 1)`

## Slotted Achievements

There are two types of achievements, `accumulative` is the only type discussed
so far.  The other type is `slotted`.  This lets you reward users for completing
many different unique actions, like completing their profile.  In order to set
up a slotted achievement you have to specify its type in the config file
(achievements are `acuumulative` by default, though this can be overridden).

```yml
achievements:
  profile:
    type: slotted
    slots:
      - picture
      - birthday
      - favorite_food
    badges:
      - required: picture
        img: getting_to_know_you
      - required:
        - picture
        - birthday
        - favorite_food
        img: identity_theft
```

The above config defines one achievement with two badges.  If you set an
achievements type to `slotted` you must also have a `slots` key which is a list
of all the possible actions that a user can take within the realm of this
achievement.  Additionally the type of the requirements field has changed from
an integer in the case of accumulation to a list of slots (strings).  For
convenience, if there is only one slot needed you may omit the list.

To achieve , you just call the `#achieve` method as before, but supply a slot as
the second argument.

`current_user.achieve(:profile, :picture)`
