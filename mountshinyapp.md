# 0. Install the R library "shiny" and "shinydashboard"

# 1. Install shiny-server on linux

# 2. test your shinny serv app, i.e. http://10.0.15.5:3838/sample-apps/

# 3. create the group shinyapps
# sudo groupadd shinyapps

# 4. Add shiny user to group shinyapps
# sudo usermod -a -G shinyapps shiny

# 5. Put your shiny app in /srv/shiny-server
# sudo rsync -avP /home/itadmin/monitor-cluster-INMEGEN /srv/shiny-server

# 6. Change group for your app
# sudo chown -R :shinyapps monitor-cluster-INMEGEN

# 7. Change permisions
# sudo chmod -R g+rwx monitor-cluster-INMEGEN/
# Verify proper permisions...

# 8. test the shiny app...
