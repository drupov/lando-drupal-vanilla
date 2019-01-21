# The site name should be passed in as a first parameter to the shell script.
siteName=$1

mkdir $siteName
cd $siteName

echo "name: $siteName" >> .lando.yml
echo "recipe: drupal8" >> .lando.yml
echo "config:" >> .lando.yml
echo "  via: nginx" >> .lando.yml
echo "  webroot: web" >> .lando.yml
echo "  xdebug: true" >> .lando.yml
echo "tooling:" >> .lando.yml
echo "  drush:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "    cmd:" >> .lando.yml
echo '      - "drush"' >> .lando.yml
echo '      - "--root=/app/web"' >> .lando.yml

lando start

lando composer create-project drupal-composer/drupal-project:8.x-dev tmp --stability dev --no-interaction
mv tmp/* .
rm -rf tmp

lando restart

lando drush site-install --account-pass=admin --db-url=mysql://drupal8:drupal8@database/drupal8 --site-name=$siteName --yes

lando composer require drupal/coffee:~1.0 drupal/admin_toolbar:~1.0 drupal/devel:~1.0
lando drush pm-enable coffee admin_toolbar_tools devel devel_generate kint webprofiler --yes

echo "Browse your site by visiting:"
lando info | grep lndo.site
