# Как разработать маленький сервис. Архитектура маленького сервиса.
Tags: bash, python, unix-way, directory as service, KISS

TODO: разбить статью на готовые рецепты для сервисов разной сложности

> Directory as service
> Минимизация зависимостей
> Unix-way
> Простота развертывания (простота документирования)
> Все под-утилиты unix-way (либо явно указываем что это подмодули другого скрипта)
> Зависимости окружения (либо самостоятельная конфигурация окружения, либо... (скрипт проверки?)) 
> Простота отладки
> KISS

***

> Статья носит сумбурный характер различных тезисов, которые нужно совмещать.


Итак, вам нужно написать простенький (но очень важный) демон/периодическую задачу/подсистему и она требует сложного окружения (преднастроенная система, совместной работы на нескольких серверах).


### Разбейте сервис на составляющие, самодостаточные части.
В bash это будут отдельные скрипты, в python скрипты либо модули(с собственными тестами).

Вспомните unix-way, постарайтесь, чтобы каждую часть можно было запустить - это поможет вам в отладке, повысит шанс пере использования, повысит абстрагирование этой подсистемы.

При разработке на bash для хорошего проектирования можно представить каждый отдельный скрипт как объект в ООП, интерфейс которого - ключи при запуске. Остерегайтесь bash-библиотек, перепишите их в виде исполняемых файлов.

Снабдите ее полноценным хелпом, вынесите важные переменные как параметры запуска (если скрипт при запуске читает файл - передавайте путь до файла; если пишет результат в файл - выводите его в stdout, либо передавайте путь в виде параметра). Обязательно в хелпе приводите примеры для каждой опции запуска.

### Разместите проект в очевидном месте (хранение и развертывание)
Если сервис является частью большей подсистемы (дашборд в crm, rest-сервер в биллинге), то положите его прямо в проект (в git к crm, в систему сборки биллинга) - тогда у вас всегда будет ожидаемое окружение, а другим людям будет понятно, что подсистема не рассчитана на использование вне его.

Использование изолированных репозиториев либо приведет к неразберихе с окружением (непонятно как запустить), либо повысит трудозатраты на разработку (работа в неизвестном окружении)

Конечно, это не относится к независимым проектам.

Если сервис не является частью окружения, но требует конфигурации специального окружения для себя (необычная строго определенная конфигурация редуктора, чистая тестовая БД crm, чистый одноразовый тестовый биллинг), то это можно решить одним из следующих способов:

 * сделать скрипты разворачивания и настройки окружения для себя
 * если репозиторий является частью большей системы, тогда она должна загружать репозиторий при разворачивании себя (желательно еще и поддерживать обновление при помощи git pull). В README проекта лучше указать для чего он предназначен
 * записать файл README с описанием того, что нужно для работы
 * сделать скрипты проверки, что окружение сконфигурировано правильно с рекомендациями по настройке
 
Выбор сильно зависит от проекта, первый вариант подходит если требуется самостоятельная установка, второй вариант требует наличия системы сборки либо проекта со сложной системой развертывания. Третий вариант наименее трудоемкий, отчего наиболее предпочтительный, последний вариант является интерактивной версией третьего, предпочтителен когда требуется частое развертывание незнакомыми с проектом людьми (например, при разработке скриптов для тех.поддержки)

Если окружение сервиса составляет более одного сервера (тестовый редуктор+саттелит, crm+gitlab) - выберите кто будет "папой" в этой паре и расположите вашу подсистему там. Придерживайтесь одностороннего общения (пусть редуктор сам подключается к саттелиту, конфигурит его и забирает с него результат). Решение должно учитывать безопасность: наприме, тестовая виртуалка не должна иметь доступ к системе тестирования, а система тестирования может иметь доступ к тестовой виртуалке. Доступ к ней по ssh сильно проще реализовать, чем какое-нибудь API для общения и сильно гибче по возможностям.

Сосредоточте все ваши скрипты в одном месте, если часть скриптов должна запускаться в дочернем окружении - перед запуском скопируйте туда нужный скрипт и копируйте его перед каждым стартом подсистемы. Это сильно упростит деплой и обновление подсистемы, понизит сложность понимания данной связки для программиста.
Например, есть скрипт посторения отчета по коммитам на gitlab. Он состоит из 2х частей: скрипта генерации отчета и скрипта сборки этого отчета для отображения в crm. Было принятно решение, что скрипт на crm будет закачивать скрипт отчета на gitlab и инициировать его генерацию. В итоге, схему работы можно понять, посмотрев 2 рядом лежащих скрипта, там же поправить их и запустить. Gitlab при этом даже не догадывается, что он интегрирован в это взаимодействие.

Если у вас подсистема работает сразу на нескольких серверах - считайте, что у вас несколько подсистем, которые связаны друг с другом, но которые должны быть самодостаточны.

Сервера сгорают, виртуалки ломаются, сконфигурированные сервера теряют конфигурацию при свежем обновлении. Следите за тем, что оставляете достаточно возможностей для повторного развертывания необходимого окружения для работы вашей подсистемы.

### Directory as service
Сосредоточте все необходимое окружение внутри каталога.
Если ваша подсистема требует специальной конфигурации хоста, создания иерархии каталогов, и прочего, тогда вам захочется написать скрипт установки, обновления (удаления?). Но можно поступить намного проще.
 
Положите все необходимое в один каталог, создайте в нем точку входа (файл service) и загитуйте. Тогда в случае необходимости деплоя вы просто сделаете git clone, при необходимости обновления - git pull, при необходимости переместить подсистему на другой сервер - необходимо только скопировать этот каталог. Обновление можно сделать, добавив симлинк на update.sh в cron.daily при установке.
 
Примеры подхода directory as service: 

 * app в платформе (здесь вместо git - система сборки)
 * gitlab embeded (он поставляется в комплекте с собственной конфигурацией postgres и redis)
 * wika (каталог /var/www находится под гитом, изменения на wika пожно подпулить на opencarbon и наоборот)
 * виртуалки makedistro и другие (сервисом является вся виртуальная машина и поставляется она целиком). 

Виртуалки makedistro, autotest, test_billing немного некорректный пример, т.к. они внутри содержат самодостаточную систему с собственным обновлением, но такие виртуалки как phplist, crm, public_influxdb, mail, pbx, carbon_cfg - являются целостными единицами, ни кто в здравом уме не станет разворачивать вторую vcrm, устанавливая и патча новый тайгер на свежую виртуалку, намного проще склонировать существующую виртуалку.

Старайтесь делать directory as service как можно меньшего формата. Один скрипт лучше директории с кучей скриптов, директория лучше чем система сборки, виртуалка - крайний случай, когда хочется один раз все настроить и больше это никогда не трогать. Чем меньше формат - тем проще понять суть, меньше зависимостей от окружения, проще протестировать, дешевле и проще поставлять.

Не создавайте directory as service на основе особенно-сконфигурированного продукта без крайней необходимости. Если ваш сервис использует БД - пусть он ее себе создаст и запишет ее в requirements. Если ваш сервис содержит особую конфигурацию БД (например, как апп asr_billing) - пусть он ее содержит внутри себя, либо содержит скрипт ее конфигурации. Нужно соблюдать баланс: содержание БД внутри себя повысит сложность и объем сервиса, а конфигурация внешней БД может нежелательно влиять на хостовую систему, например компьютер разработчика.

Вероятнее всего, вам нужен просто скрипт проверки, установки и настройки зависимостей, что позволит быстро настроить новое окружения при развертывании вашего сервиса. Все другие ситуации сложны сами по себе, основываются на многих факторов и требуют самостоятельных размышлений.

### KISS
Не забывайте про KISS, делайте все максимально просто и на 80% качественно. Но делайте. Не соблюдать стандарты кодирования, не поддерживать --help, не придерживаться unix-way, не создавать скрипты развертывания при сложном окружении - это не значит соблюдать KISS. Делайте работу качественно.
