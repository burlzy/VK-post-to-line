# VK to Line Notify script

In short, this script can be run against a specified VK page to scan for new posts. The script will then forward on any text/images via the Line Notify API to any tokens you have placed in the room_ids.txt file.

Example crontab schedule below (set to run every minute)

*/1 * * * * /home/vk-to-line.bash twdrts_game 5 > /tmp/vk_twdrts_game.out

We're passing the VK page as the first parameter (https://vk.com/twdrts_game), then the number of recent posts to fetch every minute (5). Basically hoping that the page doesn't post more than 5 posts within the space of a minute.

It then compares these 5 recent posts it has fetched to the 5 oldest posts. If there are any differences then the message_bot function will trigger and post the text/pictures of any new posts picked up.

# Requirements

- Assuming the page is public, if private make sure the user you have used to generate a VK api token has joined the group (generate your personal token here: https://vk.com/dev/access_token)
- jq is needed to strip out components sent by the VK api: https://stedolan.github.io/jq/download/
- Ensure you have a Line account created, from that you can use the Line Notify website to create tokens for rooms for the bot to post in: https://notify-bot.line.me/doc/en/
