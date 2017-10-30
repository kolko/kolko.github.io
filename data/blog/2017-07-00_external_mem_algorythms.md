# Курс лекций "Алгоритмы во внешней памяти". Максим Бабенко
Tags: читательский дневник, алгоритмы, cpumemory

[http://www.youtube.com/embed/KsPv6X9ysqI](http://www.youtube.com/embed/KsPv6X9ysqI) [http://www.lektorium.tv/lecture/13929](http://www.lektorium.tv/lecture/13929)

На курсе рассказывают про алгоритмы, которые работают с данными, которые, по тем или иным причинам, не могут поместиться в оперативную память (когда файлы лежат на HDD/SSD или, например, в хадупе на HDFS). Объясняется сложность таких алгоритмов, относительно количества дисковых операций, теория подана довольно просто и интуитивно, мозг хорошо настраивается на мысль, что не так важна производительность кода, когда доступ к данным такой дорогой.

На 3-4й лекции завтыкал, примеры про алгоритмы на графах мне не очень близки. Может, почитаю про эти алгоритмы в памяти и пересмотрю как все меняется, когда граф окажется очень большим. Но первые лекции очень хороши.

В последней [лекции](http://www.youtube.com/embed/uCfgk1sx_Pg) акцент смещают с внешней памяти и оперативной на CPU-кеш и оперативную память. Скорости тут, конечно, будут другие, но порядок, на который отличается скорость доступа к кешу и ОЗУ, и порядок ОЗУ и HDD примерно одинаков, на мой взгляд. 5 лекция будет сама по себе полезна, если тебе нужен быстрый алгоритм, который работает с данными в ОЗУ. Минимизация доступа к ОЗУ сможет дать большой прирост производительности, да и круто это, знать как работает кеш в CPU :)

Вместо пятой лекции, конечно, советую прочитать "What Every Programmer Should Know About Memory" [https://www.akkadia.org/drepper/cpumemory.pdf](https://www.akkadia.org/drepper/cpumemory.pdf) , но там много, и мне плохо зашли части про бечмаркинг скорости, т.к. нет под рукой проекта, на который я могу примерять цифры, чтобы их осознавать.