﻿#Область СлужебныйПрограммныйИнтерфейс

// Устанавливает состояние отмены при создании форм рабочего стола.
// Требуется, если при запуске программы возникает необходимость
// взаимодействия с пользователем (интерактивная обработка).
//
// Используется из одноименной процедуры в модуле СтандартныеПодсистемыКлиент.
// Прямой вызов на сервере имеет смысл для сокращения серверных вызовов,
// если при подготовке параметров клиента через модуль ПовтИсп уже
// известно, что интерактивная обработка требуется.
//
// Если прямой вызов сделан из процедуры получения параметров клиент,
// то состояние на клиенте будет обновлено автоматически, в другом случае
// это нужно сделать самостоятельно на клиенте с помощью одноименной процедуры
// в модуле СтандартныеПодсистемыКлиент.
//
// Параметры:
//  Скрыть - Булево - если установить Истина, состояние будет установлено,
//           если установить Ложь, состояние будет снято (после этого
//           можно выполнить метод ОбновитьИнтерфейс и формы рабочего
//           стола будут пересозданы).
//
Процедура СкрытьРабочийСтолПриНачалеРаботыСистемы(Скрыть = Истина) Экспорт
	
	Если ТекущийРежимЗапуска() = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Сохранение или восстановление состава форм начальной страницы.
	КлючОбъекта         = "Общее/НастройкиНачальнойСтраницы";
	КлючОбъектаХранения = "Общее/НастройкиНачальнойСтраницыПередОчисткой";
	СохраненныеНастройки = ХранилищеСистемныхНастроек.Загрузить(КлючОбъектаХранения, "");
	
	Если ТипЗнч(Скрыть) <> Тип("Булево") Тогда
		Скрыть = ТипЗнч(СохраненныеНастройки) = Тип("ХранилищеЗначения");
	КонецЕсли;
	
	Если Скрыть Тогда
		Если ТипЗнч(СохраненныеНастройки) <> Тип("ХранилищеЗначения") Тогда
			ТекущиеНастройки = ХранилищеСистемныхНастроек.Загрузить(КлючОбъекта);
			СохраняемыеНастройки = Новый ХранилищеЗначения(ТекущиеНастройки);
			ХранилищеСистемныхНастроек.Сохранить(КлючОбъектаХранения, "", СохраняемыеНастройки);
		КонецЕсли;
		СтандартныеПодсистемыСервер.УстановитьПустуюФормуНаРабочийСтол();
	Иначе
		Если ТипЗнч(СохраненныеНастройки) = Тип("ХранилищеЗначения") Тогда
			СохраненныеНастройки = СохраненныеНастройки.Получить();
			Если СохраненныеНастройки = Неопределено Тогда
				ХранилищеСистемныхНастроек.Удалить(КлючОбъекта, Неопределено,
					ПользователиИнформационнойБазы.ТекущийПользователь().Имя);
			Иначе
				ХранилищеСистемныхНастроек.Сохранить(КлючОбъекта, "", СохраненныеНастройки);
			КонецЕсли;
			ХранилищеСистемныхНастроек.Удалить(КлючОбъектаХранения, Неопределено,
				ПользователиИнформационнойБазы.ТекущийПользователь().Имя);
		КонецЕсли;
	КонецЕсли;
	
	ТекущиеПараметры = Новый Соответствие(ПараметрыСеанса.ПараметрыКлиентаНаСервере);
	
	Если Скрыть Тогда
		ТекущиеПараметры.Вставить("СкрытьРабочийСтолПриНачалеРаботыСистемы", Истина);
		
	ИначеЕсли ТекущиеПараметры.Получить("СкрытьРабочийСтолПриНачалеРаботыСистемы") <> Неопределено Тогда
		ТекущиеПараметры.Удалить("СкрытьРабочийСтолПриНачалеРаботыСистемы");
	КонецЕсли;
	
	ПараметрыСеанса.ПараметрыКлиентаНаСервере = Новый ФиксированноеСоответствие(ТекущиеПараметры);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает структуру параметров, необходимых для работы клиентского кода конфигурации
// при запуске, т.е. в обработчиках событий ПередНачаломРаботыСистемы, ПриНачалеРаботыСистемы.
//
// Только для вызова из СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиентаПриЗапуске.
//
Функция ПараметрыРаботыКлиентаПриЗапуске(Параметры) Экспорт
	
	НовыеПараметры = Новый Структура;
	ДобавитьПоправкиКВремени(НовыеПараметры, Параметры);
	
	ЗапомнитьВременныеПараметры(Параметры);
	ОбщегоНазначенияКлиентСервер.ДополнитьСтруктуру(Параметры, НовыеПараметры);
	
	ОбработатьПараметрыКлиентаНаСервере(Параметры);
	
	Если Параметры.ПолученныеПараметрыКлиента <> Неопределено Тогда
		Если НЕ Параметры.Свойство("ПропуститьОчисткуСкрытияРабочегоСтола") Тогда
			// Обновить состояние скрытия рабочего стола, если при предыдущем
			// запуске произошел сбой до момента штатного восстановления.
			СкрытьРабочийСтолПриНачалеРаботыСистемы(Неопределено);
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ СтандартныеПодсистемыСервер.ДобавитьПараметрыРаботыКлиентаПриЗапуске(Параметры) Тогда
		Возврат ФиксированныеПараметрыКлиентаБезВременныхПараметров(Параметры);
	КонецЕсли;
	
	ПользователиСлужебный.ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры, Неопределено, Ложь);
	
	ИнтеграцияПодсистемБСП.ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры);
	
	ПрикладныеПараметры = Новый Структура;
	ОбщегоНазначенияПереопределяемый.ПараметрыРаботыКлиентаПриЗапуске(ПрикладныеПараметры);
	Для Каждого Параметр Из ПрикладныеПараметры Цикл
		Параметры.Вставить(Параметр.Ключ, Параметр.Значение);
	КонецЦикла;
	
	ПрикладныеПараметры = Новый Структура;
	ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиентаПриЗапуске(ПрикладныеПараметры);
	Для Каждого Параметр Из ПрикладныеПараметры Цикл
		Параметры.Вставить(Параметр.Ключ, Параметр.Значение);
	КонецЦикла;
	
	Возврат ФиксированныеПараметрыКлиентаБезВременныхПараметров(Параметры);
	
КонецФункции

// Возвращает структуру параметров, необходимых для работы клиентского кода конфигурации. 
// Только для вызова из СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента.
//
Функция ПараметрыРаботыКлиента(СвойстваКлиента) Экспорт
	
	Параметры = Новый Структура;
	ДобавитьПоправкиКВремени(Параметры, СвойстваКлиента);
	
	ИнтеграцияПодсистемБСП.ПриДобавленииПараметровРаботыКлиента(Параметры);
	
	ПрикладныеПараметры = Новый Структура;
	ОбщегоНазначенияПереопределяемый.ПараметрыРаботыКлиента(ПрикладныеПараметры);
	Для Каждого Параметр Из ПрикладныеПараметры Цикл
		Параметры.Вставить(Параметр.Ключ, Параметр.Значение);
	КонецЦикла;
	
	ПрикладныеПараметры = Новый Структура;
	ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиента(ПрикладныеПараметры);
	Для Каждого Параметр Из ПрикладныеПараметры Цикл
		Параметры.Вставить(Параметр.Ключ, Параметр.Значение);
	КонецЦикла;
	
	Возврат ОбщегоНазначения.ФиксированныеДанные(Параметры);
	
КонецФункции

// См. РаботаВМоделиСервиса.УстановитьРазделениеСеанса.
Процедура УстановитьРазделениеСеанса(Знач Использование, Знач ОбластьДанных = Неопределено) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса") Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		МодульРаботаВМоделиСервиса.УстановитьРазделениеСеанса(Использование, ОбластьДанных);
	КонецЕсли;
	
КонецПроцедуры

// Проверяет право на отключение логики работы системы и
// скрывает рабочий стол на сервере, если право есть,
// в противном случае вызывает исключение.
// 
Процедура ПроверитьПравоОтключитьЛогикуНачалаРаботыСистемы() Экспорт
	
	СкрытьРабочийСтолПриНачалеРаботыСистемы(Истина);
	
	ВходВОбластьДанных = ОбщегоНазначения.РазделениеВключено()
		И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных();
	
	Если Не ВходВОбластьДанных
	   И Не ПравоДоступа("Администрирование", Метаданные)
	 Или ВходВОбластьДанных
	   И Не ПравоДоступа("АдминистрированиеДанных", Метаданные) Тогда
		
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для работы с отключенной логикой работы системы.'");
	КонецЕсли;
	
	ПользователиСлужебный.ПроверитьПраваТекущегоПользователяПриВходе();
	
КонецПроцедуры

// Только для внутреннего использования.
Функция ЗаписатьОшибкуВЖурналРегистрацииПриЗапускеИлиЗавершении(ПрекратитьРаботу, Знач Событие, Знач ТекстОшибки) Экспорт
	
	Если Событие = "Запуск" Тогда
		ИмяСобытия = НСтр("ru = 'Запуск программы'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
		Если ПрекратитьРаботу Тогда
			НачалоОписанияОшибки = НСтр("ru = 'Возникла исключительная ситуация при запуске программы. Запуск программы аварийно завершен.'");
		Иначе
			НачалоОписанияОшибки = НСтр("ru = 'Возникла исключительная ситуация при запуске программы.'");
		КонецЕсли;
	Иначе
		ИмяСобытия = НСтр("ru = 'Завершение программы'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
		НачалоОписанияОшибки = НСтр("ru = 'Возникла исключительная ситуация при завершении программы.'");
	КонецЕсли;
	
	ОписаниеОшибки = НачалоОписанияОшибки
		+ Символы.ПС + Символы.ПС
		+ ТекстОшибки;
	ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки);
	Возврат НачалоОписанияОшибки;

КонецФункции

// Вызывается из обработчика ожидания каждые 20 минут, например, для контроля
// динамического обновления и окончания срока действия учетной записи пользователя.
//
// Параметры:
//  Параметры - Структура - в структуру следует вставить свойства для дальнейшего анализа на клиенте.
//
Процедура ПриВыполненииСтандартныхПериодическихПроверокНаСервере(Параметры) Экспорт
	
	Параметры.Вставить("КонфигурацияБазыДанныхИзмененаДинамически", КонфигурацияБазыДанныхИзмененаДинамически()
		Или Справочники.ВерсииРасширений.РасширенияИзмененыДинамически());
	
	ПользователиСлужебный.ПриВыполненииСтандартныхПериодическихПроверокНаСервере(Параметры);
    
    Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЦентрМониторинга") Тогда
        
        МодульЦентрМониторингаСлужебный = ОбщегоНазначения.ОбщийМодуль("ЦентрМониторингаСлужебный");
		МодульЦентрМониторингаСлужебный.ПриВыполненииСтандартныхПериодическихПроверокНаСервере(Параметры.ЦентрМониторинга);
               
    КонецЕсли;
    	
КонецПроцедуры

// Возвращает полное имя объекта метаданных по его типу.
Функция ПолноеИмяОбъектаМетаданных(Тип) Экспорт
	ОбъектМетаданных = Метаданные.НайтиПоТипу(Тип);
	Если ОбъектМетаданных = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	Возврат ОбъектМетаданных.ПолноеИмя();
КонецФункции

// Возвращает имя объекта метаданных по типу.
//
// Параметры:
//  Источник - Тип - объект.
// 
// Возвращаемое значение:
//   Строка.
Функция ИмяОбъектаМетаданных(Тип) Экспорт
	ОбъектМетаданных = Метаданные.НайтиПоТипу(Тип);
	Если ОбъектМетаданных = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	Возврат ОбъектМетаданных.Имя;
КонецФункции

// См. СтандартныеПодсистемыСервер.ВерсияБиблиотеки.
Функция ВерсияБиблиотеки() Экспорт
	
	Возврат СтандартныеПодсистемыСервер.ВерсияБиблиотеки();
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Работа с предопределенными данными.

// См. СтандартныеПодсистемыПовтИсп.СсылкиПоИменамПредопределенных
Функция СсылкиПоИменамПредопределенных(ПолноеИмяОбъектаМетаданных) Экспорт
	
	Возврат СтандартныеПодсистемыПовтИсп.СсылкиПоИменамПредопределенных(ПолноеИмяОбъектаМетаданных);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

Процедура ДобавитьПоправкиКВремени(Параметры, СвойстваКлиента)
	
	ДатаСеанса = ТекущаяДатаСеанса();
	ДатаСеансаУниверсальная = УниверсальноеВремя(ДатаСеанса, ЧасовойПоясСеанса());
	
	Параметры.Вставить("ПоправкаКВремениСеанса", ДатаСеанса - СвойстваКлиента.ТекущаяДатаНаКлиенте);
	Параметры.Вставить("ПоправкаКУниверсальномуВремени", ДатаСеансаУниверсальная - ДатаСеанса);
	Параметры.Вставить("СмещениеСтандартногоВремени", СмещениеСтандартногоВремени(ЧасовойПоясСеанса()));
	Параметры.Вставить("СмещениеДатыКлиента", ТекущаяУниверсальнаяДатаВМиллисекундах()
		- СвойстваКлиента.ТекущаяУниверсальнаяДатаВМиллисекундахНаКлиенте);
	
КонецПроцедуры

Процедура ЗапомнитьВременныеПараметры(Параметры)
	
	Параметры.Вставить("ИменаВременныхПараметров", Новый Массив);
	
	Для каждого КлючИЗначение Из Параметры Цикл
		Параметры.ИменаВременныхПараметров.Добавить(КлючИЗначение.Ключ);
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработатьПараметрыКлиентаНаСервере(Знач Параметры)
	
	ПривилегированныйРежимУстановленПриЗапуске = ПривилегированныйРежим();
	УстановитьПривилегированныйРежим(Истина);
	
	Если ПараметрыСеанса.ПараметрыКлиентаНаСервере.Количество() = 0 Тогда
		// Первый серверный вызов с клиента при запуске.
		ПараметрыКлиента = Новый Соответствие;
		ПараметрыКлиента.Вставить("ПараметрЗапуска", Параметры.ПараметрЗапуска);
		ПараметрыКлиента.Вставить("СтрокаСоединенияИнформационнойБазы", Параметры.СтрокаСоединенияИнформационнойБазы);
		ПараметрыКлиента.Вставить("ПривилегированныйРежимУстановленПриЗапуске", ПривилегированныйРежимУстановленПриЗапуске);
		ПараметрыКлиента.Вставить("ЭтоВебКлиент", Параметры.ЭтоВебКлиент);
		ПараметрыКлиента.Вставить("ЭтоВебКлиентПодMacOS", Параметры.ЭтоВебКлиентПодMacOS);
		ПараметрыКлиента.Вставить("ЭтоМобильныйКлиент", Параметры.ЭтоМобильныйКлиент);
		ПараметрыКлиента.Вставить("ЭтоLinuxКлиент", Параметры.ЭтоLinuxКлиент);
		ПараметрыКлиента.Вставить("ЭтоOSXКлиент", Параметры.ЭтоOSXКлиент);
		ПараметрыКлиента.Вставить("ЭтоWindowsКлиент", Параметры.ЭтоWindowsКлиент);
		ПараметрыКлиента.Вставить("ИспользуемыйКлиент", Параметры.ИспользуемыйКлиент);
		ПараметрыКлиента.Вставить("ОперативнаяПамять", Параметры.ОперативнаяПамять);
		ПараметрыКлиента.Вставить("КаталогПрограммы", Параметры.КаталогПрограммы);
		ПараметрыКлиента.Вставить("ИдентификаторКлиента", Параметры.ИдентификаторКлиента);
		ПараметрыКлиента.Вставить("РазрешениеОсновногоЭкрана", Параметры.РазрешениеОсновногоЭкрана);
		ПараметрыСеанса.ПараметрыКлиентаНаСервере = Новый ФиксированноеСоответствие(ПараметрыКлиента);
		
		Если СтрНайти(НРег(Параметры.ПараметрЗапуска), НРег("ЗапуститьОбновлениеИнформационнойБазы")) > 0 Тогда
			ОбновлениеИнформационнойБазыСлужебный.УстановитьЗапускОбновленияИнформационнойБазы(Истина);
		КонецЕсли;
		
		Если Не ОбщегоНазначения.РазделениеВключено() Тогда
			Если ПланыОбмена.ГлавныйУзел() <> Неопределено
				Или ЗначениеЗаполнено(Константы.ГлавныйУзел.Получить()) Тогда
				// Предотвращение случайного обновления предопределенных данных в подчиненном узле РИБ:
				// - при запуске с временно отмененным главным узлом;
				// - при реструктуризации данных в процессе восстановления узла.
				Если ПолучитьОбновлениеПредопределенныхДанныхИнформационнойБазы()
					<> ОбновлениеПредопределенныхДанных.НеОбновлятьАвтоматически Тогда
					УстановитьОбновлениеПредопределенныхДанныхИнформационнойБазы(
					ОбновлениеПредопределенныхДанных.НеОбновлятьАвтоматически);
				КонецЕсли;
				Если ПланыОбмена.ГлавныйУзел() <> Неопределено
					И Не ЗначениеЗаполнено(Константы.ГлавныйУзел.Получить()) Тогда
					// Сохранение главного узла для возможности восстановления.
					СтандартныеПодсистемыСервер.СохранитьГлавныйУзел();
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Функция ФиксированныеПараметрыКлиентаБезВременныхПараметров(Параметры)
	
	ПараметрыКлиента = Параметры;
	Параметры = Новый Структура;
	
	Для каждого ИмяВременногоПараметра Из ПараметрыКлиента.ИменаВременныхПараметров Цикл
		Параметры.Вставить(ИмяВременногоПараметра, ПараметрыКлиента[ИмяВременногоПараметра]);
		ПараметрыКлиента.Удалить(ИмяВременногоПараметра);
	КонецЦикла;
	Параметры.Удалить("ИменаВременныхПараметров");
	
	УстановитьПривилегированныйРежим(Истина);
	
	Параметры.СкрытьРабочийСтолПриНачалеРаботыСистемы =
		ПараметрыСеанса.ПараметрыКлиентаНаСервере.Получить(
			"СкрытьРабочийСтолПриНачалеРаботыСистемы") <> Неопределено;
	
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат ОбщегоНазначения.ФиксированныеДанные(ПараметрыКлиента);
	
КонецФункции

#КонецОбласти
