Member states:

# using slicer to highlight only the values of the selection

Hi, 

I know the basic concepts of Row Level Security (RLS) where selected users can see only their relevant data while other users data will be completely blinded. But I want to show other users data to the selected user while their name will be blinded but not the data values. So, the idea is when I select a user from the slicer it will show PBI visuals with the relevant data of all users but mask will other users name. Not sure if it can be doable in other ways, feel free to share your ideas here

here is the following visual that I want to implement:

![Screenshot](https://github.com/MartinBubenheimer/powerbi-solutions/blob/main/community-solutions/blinded-users/blinded-users-1.png?raw=true)

with the selection of any user from the slicer the box plot will show up the user name only but other users will be still there as blinded with their values.

![Screenshot](https://github.com/MartinBubenheimer/powerbi-solutions/blob/main/community-solutions/blinded-users/blinded-users-2.png?raw=true)

# Solution

Check the attached file <https://github.com/MartinBubenheimer/powerbi-solutions/raw/main/community-solutions/blinded-users/blinded-users.pbix> for the pattern you need. For the bi-directional relationship, it's important to turn on the setting that security is applied in both directions.

The security role that you need to apply is "Blinded Users".

The users that you can test are:

user.a@test.com

user.b@test.com

user.c@test.com

Check this video if you need instructions how to test dynamic row level security with users in Power BI Desktop: [https://www.youtube.com/watch?v=_AxXeGoqHg4](https://www.youtube.com/watch?v=_AxXeGoqHg4)

![Screenshot](https://github.com/MartinBubenheimer/powerbi-solutions/blob/main/community-solutions/blinded-users/blinded-users.png?raw=true)
