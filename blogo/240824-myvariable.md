# หลักการตั้งตัวแปร
การเขียนโปรแกรมของกระผมเป็นเพียงแค่งานอดิเรกเท่านั้น แต่งานอดิเรกนี้ทำให้กระผมได้เรียนรู้สิ่งต่าง ๆ มากมาย จากการศึกษาโค้ดของนักเขียนโปรแกรมของคนอื่น [https://google.github.io/styleguide/jsguide.html](แนวทางการเขียนโค้ด JavaScript) ของ Google ตอนนี้ผมได้กำหนดแนวทางในการตั้งชื่อตัวแปรในการเขียน JavaScript ซึ่งเป็นแนวทางของผมเองเท่านั้น โดยใช้รูปแบบ camelCase สำหรับการตั้งตัวแปรชนิด string และชื่อ funtion แบบ camelCase แบบปกติที่ทำกันอยู่แล้ว ส่วน number และ array จะใช้แบบ UPPERCASE_WITH_UNDERSCORE ส่วนแบบอื่น ยังไม่ได้คิด...

```javascript
let strings = "my variable";
let myStrings ="I love my dog";

function myFunction() {
    console.log("hi!")
}

const NUMBER = 199;
const MY_NUMBERS = 1234567890;

const MY_ARRAY = ["หมู", "หมา", "กา", "ไก่"];
```

## สรุป
1. ตัวอักษร (string), ชื่อฟังก์ชัน camelCase
2. ตัวเลข (number), อาเรย์ (array) UPPER_CASE_WITH_UNDERSCORE