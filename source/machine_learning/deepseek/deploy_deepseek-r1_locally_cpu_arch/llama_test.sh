curl -X POST "http://localhost:8080/completion" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "编写bash脚本，检查字符串A是否包含在字符串B中，并给出脚本解释"}'
