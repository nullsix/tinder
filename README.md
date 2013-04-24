tinder
======

Get feedback from others on creative pieces.

Setting up a development environment
====================================

The easy way
------------
There is no easy way just yet! Sorry!

The hard way
------------

Install PostgreSQL 9.2.x, git, Ruby 2.0.0-p0, and bundler

Ubuntu
> apt-get install postgresql git

Fedora
> yum install postgresql-server git

Gentoo/Sabayon
> emerge dev-db/postgresql-server  # Latest binary PostgreSQL is currently 9.1.9 on Sabayon
> emerge git
> equo install git

MacOS
See http://www.postgresql.org/download/macosx/

Install Ruby 2.0.0-p0 http://www.ruby-lang.org
It's recommended to use one of the following methods to help manage/install Ruby:

chruby: https://github.com/postmodern/chruby
RVM: https://rvm.io/rvm/install/
rbenv: https://github.com/sstephenson/rbenv/

Install bundler
> gem install bundler

Clone the repository - git://github.com/nullsix/tinder.git
> git clone git://github.com/nullsix/tinder.git
> cd tinder
> bundle install

Create a Postgres user/role
> psql -U postgres
> CREATE ROLE tinder CREATEDB LOGIN ENCRYPTED PASSWORD 'tinder1';
> \q

Or you can use the following tool and set the username to 'tinder' and the password to 'tinder1':
> createuser -P

Then create the database and load the schema:
> rake db:create
> rake db:schema:load

To test simply run RSpec:
> rake spec

