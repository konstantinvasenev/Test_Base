﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура УстановкаПараметровСеанса(ИменаПараметровСеанса)
	
	// Установка параметра сеанса подсистемы "Оценка производительности" при использовании отдельно от БСП.
	ОценкаПроизводительностиСлужебный.УстановкаПараметровСеанса("КомментарийЗамераВремени", Новый Массив);
	
	// ТестЦентр
	ТЦСервер.УстановитьПараметрыСеанса(ИменаПараметровСеанса);
	// Конец ТестЦентр
	
	// СтандартныеПодсистемы
	СтандартныеПодсистемыСервер.УстановкаПараметровСеанса(ИменаПараметровСеанса);
	// Конец СтандартныеПодсистемы
		
КонецПроцедуры

#КонецОбласти

#КонецЕсли