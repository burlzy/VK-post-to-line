vkpage="$1"
count="$2"
room_ids="tom/room_ids.txt"

file="oldposts_$vkpage.txt"
if [ -e "$file" ]; then
    echo "File exists"
else
    echo "File does not exist"
    touch oldposts_$vkpage.txt
fi

identical()
{
    echo "No change, nothing to alert line api about"
    exit 1
}

data()
{
    echo -e $(cat post_message_$vkpage.txt)
}

message_bot()
{
    echo "beep boop"
    echo "New post detected - alerting line bot"
    latest_ids=$(jq '.response.items[]?.id' $latest_posts | sort)
    echo $latest_ids
    old_ids=$(jq '.response.items[]?.id' $old_posts | sort)
    echo $old_ids
    post_ids=$(echo ${old_ids[@]} ${old_ids[@]} ${latest_ids[@]} | tr ' ' '\n' | sort | uniq -u)
    echo $post_ids
    for i in $post_ids
    do
        if grep -w --quiet $i processed_ids_$vkpage.txt; then
            echo "exists - not posting duplicate entry"
            continue
        fi
        
        echo $i >> processed_ids_$vkpage.txt
        
        post_message=$(jq '.response.items[]? | select(.id=='$i') .text' $latest_posts |  sed 's/^"//' | sed s'/.$//')
        if [[ ! $post_message ]]; then
            echo "no post text - skipping"
            continue
        fi
        echo $post_message > post_message_$vkpage.txt
        echo $i
        for j in $(jq '.response.items[]? | select(.id=='$i')| .attachments[]?.photo.id ' $latest_posts)
        do
            for token in $(cat $room_ids)
            do
                image=$(jq '.response.items[]?.attachments[]?.photo | select(.id=='$j')' $latest_posts | jq '.sizes' | grep "url" | tail -1 |  cut -d\" -f4)
                curl -X POST \
                -H "Authorization: Bearer $token" \
                -F $'message=" "' \
                -F "imageThumbnail=$image" \
                -F "imageFullsize=$image" https://notify-api.line.me/api/notify &
            done
            wait
        done
        for token in $(cat $room_ids)
        do
            curl -X POST \
            -H "Authorization: Bearer $token" \
            -F $'message="\n'"$(data)"'"' https://notify-api.line.me/api/notify
        done
    done
    cp $latest_posts $old_posts
}


curl -sG "https://api.vk.com/method/wall.get?domain=$vkpage&extended=1&count=$count&v=5.131&access_token=$access_token" > latest_$vkpage.txt

latest_posts="latest_$vkpage.txt"
old_posts="oldposts_$vkpage.txt"

if [ ! -z "$(cmp latest_$vkpage.txt oldposts_$vkpage.txt 2>&1)" ]
then
    message_bot
else
    identical
fi
