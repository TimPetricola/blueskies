# Blue Skies [![Build Status](https://api.travis-ci.org/TimPetricola/blueskies.svg?branch=master)](https://travis-ci.org/TimPetricola/blueskies) [![Code Climate](https://codeclimate.com/github/TimPetricola/blueskies/badges/gpa.svg)](https://codeclimate.com/github/TimPetricola/blueskies)


Blue Skies is an automatically curated digest. It is originally made for air
sports but can be used for any kind of digest.

## Automatic curation

Blue Skies is based on Facebook pages to get new links. Trused facebook pages
can be added to the database. A worker will then fetch new link from these pages
regularly.

## Setup

```
bundle install
createdb blueskies_development
rake db:migrate
```

## Configuration

Several environment variables are needed. You can copy `.sample.env` into a
`.env` file and tweak your configuration there.

## Seeding

Open a console:

```
foreman run pry -r ./app
```

And add curators:

```rb
BlueSkies::Models::Curator.create(facebook_identifier: 'facebook_page')
```

You can also add some interests:

```rb
BlueSkies::Models::Interest.create(name: 'Blue Skies')
```

## Development

```
npm install
foreman run dev
foreman run web
foreman run worker
```

## Testing

```
createdb blueskies_test
rake db:test
```
