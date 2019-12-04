﻿
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	Движения.ОстаткиНоменклатуры.Записать();
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = "ВЫБРАТЬ
	               |	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура,
	               |	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
	               |	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма
	               |ПОМЕСТИТЬ ТЧ
	               |ИЗ
	               |	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
	               |ГДЕ
	               |	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
	               |	И РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ВидыНоменклатуры.Товар)
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Результат = Запрос.Выполнить();
	Если Не Результат.Пустой() Тогда 
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ОстаткиНоменклатуры");
		ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
		ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();
		
		Запрос.Текст = "ВЫБРАТЬ
		               |	ТЧ.Номенклатура КАК Номенклатура,
		               |	ПРЕДСТАВЛЕНИЕ(ТЧ.Номенклатура),
		               |	ОстаткиНоменклатурыОстатки.Склад,
		               |	ЕСТЬNULL(ОстаткиНоменклатурыОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
		               |	ЕСТЬNULL(ОстаткиНоменклатурыОстатки.СуммаОстаток, 0) КАК СуммаОстаток,
		               |	ТЧ.Количество,
		               |	ТЧ.Сумма
		               |ПОМЕСТИТЬ ВТ_Склады
		               |ИЗ
		               |	ТЧ КАК ТЧ
		               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ОстаткиНоменклатуры.Остатки(
		               |				&МоментВремени,
		               |				Номенклатура В
		               |					(ВЫБРАТЬ
		               |						ТЧ.Номенклатура
		               |					ИЗ
		               |						ТЧ)) КАК ОстаткиНоменклатурыОстатки
		               |		ПО ТЧ.Номенклатура = ОстаткиНоменклатурыОстатки.Номенклатура
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	ВТ_Склады.Номенклатура КАК Номенклатура,
		               |	ВТ_Склады.НоменклатураПредставление,
		               |	ВТ_Склады.Склад,
		               |	ВТ_Склады.КоличествоОстаток КАК КоличествоОстаток,
		               |	ВТ_Склады.СуммаОстаток КАК СуммаОстаток,
		               |	ВТ_Склады.Количество КАК Количество,
		               |	ВТ_Склады.Сумма КАК Сумма,
		               |	ВЫБОР
		               |		КОГДА ВТ_Склады.Склад = &Склад
		               |			ТОГДА -1
		               |		ИНАЧЕ ПриоритетыСкладовСрезПоследних.Приоритет
		               |	КОНЕЦ КАК Приоритет
		               |ИЗ
		               |	ВТ_Склады КАК ВТ_Склады
		               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПриоритетыСкладов.СрезПоследних(
		               |				&МоментВремени,
		               |				Склад В
		               |					(ВЫБРАТЬ
		               |						ВТ_Склады.Склад
		               |					ИЗ
		               |						ВТ_Склады КАК ВТ_Склады)) КАК ПриоритетыСкладовСрезПоследних
		               |		ПО ВТ_Склады.Склад = ПриоритетыСкладовСрезПоследних.Склад
		               |
		               |УПОРЯДОЧИТЬ ПО
		               |	Приоритет
		               |ИТОГИ
		               |	СУММА(КоличествоОстаток),
		               |	СУММА(СуммаОстаток),
		               |	МАКСИМУМ(Количество),
		               |	МАКСИМУМ(Сумма)
		               |ПО
		               |	Номенклатура";
		Запрос.УстановитьПараметр("Склад", Склад);
		Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
		ВыборкаНоменклатура = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаНоменклатура.Следующий() Цикл 
			Если ВыборкаНоменклатура.Количество > ВыборкаНоменклатура.КоличествоОстаток Тогда 
				Сообщить("Недостаток товара " + ВыборкаНоменклатура.НоменклатураПредставление + "на складах");
				Отказ = Истина;
				Возврат;
			КонецЕсли;
			
			ОсталосьСписать = ВыборкаНоменклатура.Количество;
			Выборка = ВыборкаНоменклатура.Выбрать();
			Пока Выборка.Следующий() Цикл 
				Списываем = Мин(ОсталосьСписать, Выборка.КоличествоОстаток);
				
				Движение = Движения.ОстаткиНоменклатуры.ДобавитьРасход();
				Движение.Период = Дата;
				Движение.Номенклатура = Выборка.Номенклатура;
				Движение.Склад = Выборка.Склад;
				Движение.Количество = Списываем;
				Движение.Сумма = Списываем / Выборка.КоличествоОстаток * Выборка.СуммаОстаток;
				
				ОсталосьСписать = ОсталосьСписать - Списываем;
			КонецЦикла;	
		КонецЦикла;
			
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	  СуммаПоДокументу = СписокНоменклатуры.Итог("Сумма");
КонецПроцедуры
