#!/usr/bin/env bash

markdown_to_html() {
    local src="$1"
    local out="$2"

    # แปลง Markdown → HTML ด้วย markdown-it
    # content_html จะ redirect ลง output เลย
    markdown-it "$src" > "$out"
}

BLOG_NAME="ปูมของข้าพเจ้า"
BLOG_AUTHOR="นายเพนกวิน"
BLOG_DESCRIPTION="ดอกไม้ผลิบาน ใบไม้ร่วงโรย เขียนเรี่อยเปื่อย..."
footer="<a href="./tags.html">ดูแท็กทั้งหมด</a><br>CC by-nc-nd - $BLOG_AUTHOR - <a href="rss.xml">ติดตามบล็อก</a><br/>บล็อกนี้สร้างด้วยไฟล์ bash ไฟล์เดียว จากแรงบันดาลใจจาก <a href="https://github.com/cfenollosa/bashblog">bashblog</a>"
BLOG_URL="https://warut92.github.io/blog/html"

DATA_DIR="./data"
OUT_DIR="./html"
INDEX_FILE="$OUT_DIR/index.html"
TAG_FILE="$OUT_DIR/tags.html"
RSS_FILE="$OUT_DIR/rss.xml"

mkdir -p "$OUT_DIR"

echo "Cleaning old HTML files..."
rm -f "$OUT_DIR"/*.html "$OUT_DIR"/*.xml

declare -A TAG_MAP
POST_LIST=()   # เก็บโพสต์ทั้งหมดไว้เรียงทีหลัง

RSS_ITEMS=""

###########################################
# อ่านไฟล์ .md ทีละไฟล์
###########################################
for file in "$DATA_DIR"/*.md; do
    [ -e "$file" ] || continue
    
    CURRENT_MD_FILE="$file" 

    filename=$(basename "$file" .md)
    output="$OUT_DIR/$filename.html"

    # ชื่อเรื่อง = บรรทัดแรก
    title=$(head -n 1 "$file")

    # แท็ก = บรรทัดสุดท้าย
    tags_line=$(tail -n 1 "$file")

    # อ่านบรรทัดที่ 2 ถ้าเป็น DATE:
    second_line=$(sed -n '2p' "$file")

    if echo "$second_line" | grep -q "^DATE:"; then
        post_date=$(echo "$second_line" | sed 's/DATE:[ ]*//')
        pubdate_rss=$(date -d "$post_date" +"%a, %d %b %Y %H:%M:%S %z")
        content_start_line=3
    else
        post_date=$(date -r "$file" +"%Y-%m-%d")
        pubdate_rss=$(date -r "$file" +"%a, %d %b %Y %H:%M:%S %z")
        content_start_line=2
    fi

    # แปลงแท็ก
    tags=()
    while read -r tag; do
        clean=$(echo "$tag" | sed 's/^\[//; s/\]$//')
        tags+=("$clean")
    done <<< "$(echo "$tags_line" | grep -o '\[[^]]*\]')"

    ###########################################
    # สร้าง HTML ของโพสต์
    ###########################################
   # สร้างไฟล์ Markdown ชั่วคราว สำหรับเอา title, DATE, tag ออก
    tmp_md=$(mktemp)
    sed "1,${content_start_line}d" "$file" | sed '$d' > "$tmp_md"

    # แปลง Markdown → HTML แล้ว redirect ลง output
    {
        echo "<html><head><meta charset='utf-8'> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> <title>$title</title><link rel=\"stylesheet\" href=\"../css/mystyle.css\" type=\"text/css\" /></head><body>"
        echo "<a href=\"./index.html\">[หน้าหลัก]</a>"
        echo "<h1>$title</h1>"
        echo "<p>Date: $post_date - $BLOG_AUTHOR</p>"
        echo "<hr>"
        markdown-it "$tmp_md"
        echo "<hr>"
        echo "<p><b>Tags:</b>"
        for t in "${tags[@]}"; do
            tag_slug=$(echo "$t" | tr ' ' '_' )
            echo "<a href='tags_$tag_slug.html'>[$t]</a> "
        done
        echo "</p><hr><center>$footer</center></body></html>"
    } > "$output"

    rm "$tmp_md"


    ###########################################
    # เก็บโพสต์ไว้จัดเรียงทีหลัง
    ###########################################
    POST_LIST+=("$post_date|$filename.html|$title")

    ###########################################
    # จัดข้อมูลแท็ก
    ###########################################
    for t in "${tags[@]}"; do
        TAG_MAP["$t"]+="$filename.html|$title|$post_date;"
    done

    ###########################################
    # เพิ่มรายการใน RSS
    ###########################################
    RSS_ITEMS+="
<item>
  <title>$(echo "$title" | sed 's/&/\&amp;/g')</title>
  <link>$BLOG_URL/$filename.html</link>
  <pubDate>$pubdate_rss</pubDate>
  <description><![CDATA[$(sed '1d;$d' "$file")]]></description>
</item>"
done

###########################################
# สร้าง index.html แบบเรียงวันที่ (ใหม่ → เก่า)
###########################################
echo "<html><head><meta charset='utf-8'><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>$BLOG_NAME</title><link rel="stylesheet" href="../css/mystyle.css" type="text/css" /></head><body><h1>$BLOG_NAME</h1><p>$BLOG_DESCRIPTION</p><ol>" > "$INDEX_FILE"

sorted_posts=$(printf "%s\n" "${POST_LIST[@]}" | sort -r)

while IFS="|" read -r date file title; do
    echo "<li><a href='$file'>$title</a> - $date</li>" >> "$INDEX_FILE"
done <<< "$sorted_posts"

echo "</ol><hr><center>$footer</center>" >> "$INDEX_FILE"

###########################################
# สร้างหน้าแท็ก
###########################################
echo "<html><head><meta charset='utf-8'><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>$BLOG_NAME</title><link rel="stylesheet" href="../css/mystyle.css" type="text/css" /></head><body><h1>$BLOG_NAME</h1><h>แท็กทั้งหมด</h><ul>" > "$TAG_FILE"

for tag in "${!TAG_MAP[@]}"; do
    tag_slug=$(echo "$tag" | tr ' ' '_' )

    if [[ -z "$tag_slug" ]]; then
        echo "ERROR: tag_slug ว่าง! tag='$tag'"
        echo "เกิดในไฟล์: $0 (Line: ${LINENO})"
        echo "มาจากไฟล์ต้นทาง: $CURRENT_MD_FILE"
        continue
    fi

    if ! [[ "$tag_slug" =~ ^.+$ ]]; then
        echo "ERROR: tag_slug ผิดรูปแบบ → '$tag_slug'"
        echo "เกิดในไฟล์: $0 (Line: ${LINENO})"
        echo "มาจากไฟล์ต้นทาง: $CURRENT_MD_FILE"
        continue
    fi

    tag_page="$OUT_DIR/tags_$tag_slug.html"

    echo "<li><a href='tags_$tag_slug.html'>[$tag]</a></li>" >> "$TAG_FILE"

    {
        echo "<html><head><meta charset='utf-8'><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Tag: $tag</title><link rel="stylesheet" href="../css/mystyle.css" type="text/css" /></head><body>"
        echo "<h1>แท็ก: $tag</h1><ul>"
        IFS=';' read -ra entries <<< "${TAG_MAP[$tag]}"
        for entry in "${entries[@]}"; do
            [[ -z "$entry" ]] && continue
            filelink=$(echo "$entry" | cut -d '|' -f1)
            title=$(echo "$entry" | cut -d '|' -f2)
            datep=$(echo "$entry" | cut -d '|' -f3)
            echo "<li><a href='$filelink'>$title</a> - $datep</li>"
        done
        echo "</ul><hr><center>$footer</center></body></html>"
    } > "$tag_page"
done

echo "</ul>" >> "$TAG_FILE"

###########################################
# สร้าง RSS Feed
###########################################
{
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
echo "<rss version=\"2.0\">"
echo "<channel>"
echo "  <title>$BLOG_NAME</title>"
echo "  <link>$BLOG_URL</link>"
echo "  <description>RSS feed for $BLOG_NAME</description>"
echo "$RSS_ITEMS"
echo "</channel>"
echo "</rss>"
} > "$RSS_FILE"

echo "Build Completed (with Date Sorting + RSS)."
