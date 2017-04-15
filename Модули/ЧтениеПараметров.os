#Использовать json

Перем мЧтениеJSON;
Перем мПрочитанныеПараметры;
Перем мОшибкиЧтения;

// Читает параметры из переданного объекта
//
// Параметры:
//  пОбъектЧтения  - Строка, Файл, Массив, Структура, Соответствие из строк и файлов - перечень путей к файлу или файлов
//					 из которых нужно прочитать параметры
//	пОшибкиЧтения - Соответствие - имя файла и описание ошибки, если не удалось прочитать параметры
//
// Возвращаемое значение:
//   Соответствие   - Параметры, прочитанные в соответствие
//
Функция Прочитать( Знач пОбъектЧтения, пОшибкиЧтения = Неопределено ) Экспорт
	
	массивФайловДляЧтения = Новый Массив;

	ПрочитатьОбъектСФайламиРекурсивно( пОбъектЧтения, массивФайловДляЧтения );

	Если пОшибкиЧтения = Неопределено
		ИЛИ Не ТипЗнч( пОшибкиЧтения ) = Тип("Соответствие") Тогда
		пОшибкиЧтения = Новый Соответствие;
	КонецЕсли;

	мЧтениеJSON = Новый ПарсерJSON;
	мОшибкиЧтения = Новый Соответствие;
	мПрочитанныеПараметры = Новый Соответствие;

	Для каждого цИмяФайл Из массивФайловДляЧтения Цикл
		
		ПрочитатьФайл( цИмяФайл );
		
	КонецЦикла;

	ВыполнитьПодстановки();

	Возврат мПрочитанныеПараметры;	
	
КонецФункции

Процедура ПрочитатьОбъектСФайламиРекурсивно( Знач пОбъектЧтения, пМассивПрочитанныхЗначений )
	
	Если ТипЗнч( пОбъектЧтения ) = Тип("Строка") Тогда
		ДобавитьВМассив( пМассивПрочитанныхЗначений, пОбъектЧтения );
	ИначеЕсли ТипЗнч( пОбъектЧтения ) = Тип( "Файл" ) Тогда
		ДобавитьВМассив( пМассивПрочитанныхЗначений, пОбъектЧтения.ПолноеИмя );
	ИначеЕсли ТипЗнч( пОбъектЧтения ) = Тип("Массив") Тогда
		Для каждого цЭлемент Из пОбъектЧтения Цикл
			ПрочитатьОбъектСФайламиРекурсивно( цЭлемент, пМассивПрочитанныхЗначений );
		КонецЦикла;
	ИначеЕсли ТипЗнч( пОбъектЧтения ) = Тип("Структура")
		ИЛИ ТипЗнч( пОбъектЧтения ) = Тип("Соответствие") Тогда
		Для каждого цЭлемент Из пОбъектЧтения Цикл
			ПрочитатьОбъектСФайламиРекурсивно( цЭлемент.Значение, пМассивПрочитанныхЗначений );
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьВМассив( пМассив, Знач пЗначение, Знач пТолькоУникальныеЗначения = Истина)
	
	Если пТолькоУникальныеЗначения Тогда
		
		Если пМассив.Найти( пЗначение ) = Неопределено Тогда
			пМассив.Добавить(пЗначение);
		КонецЕсли;

	Иначе
		пМассив.Добавить( пЗначение );
	КонецЕсли;
	
КонецПроцедуры

Процедура ПрочитатьФайл( Знач пИмяФайл )
	
	Если Не ФайлСуществует( пИмяФайл ) Тогда			
		мОшибкиЧтения.Вставить( пИмяФайл, "Не существует");
		Возврат;			
	КонецЕсли;
	
	Попытка
		текстФайла = ПолучитьТекстИзФайла( пИмяФайл );
	Исключение
		мОшибкиЧтения.Вставить( пИмяФайл, "Не удалось прочитать текст. " + ОписаниеОшибки());
		Возврат;
	КонецПопытки;
	
	Попытка
		параметрыИзФайла = мЧтениеJSON.ПрочитатьJSON(текстФайла,,,Истина);
	Исключение
		мОшибкиЧтения.Вставить( пИмяФайл, "Не удалось прочитать JSON. " + ОписаниеОшибки());
		Возврат;
	КонецПопытки;
	ПрочитатьПараметрыРекурсивно( параметрыИзФайла );
	
КонецПроцедуры

Процедура ПрочитатьПараметрыРекурсивно( Знач пПараметры )
	
	Для каждого цЭлемент Из пПараметры Цикл
		
		Если ТипЗнч( цЭлемент.Значение ) = Тип("Структура")
			ИЛИ ТипЗнч( цЭлемент.Значение ) = Тип("Соответствие") Тогда
			
			ПрочитатьПараметрыРекурсивно( цЭлемент.Значение );
			
		Иначе
			
			мПрочитанныеПараметры.Вставить( цЭлемент.Ключ, цЭлемент.Значение );

			Если СтрНачинаетсяС( ВРег( цЭлемент.Ключ ), ВРег( Префикс_ПрочитатьФайл()) ) Тогда
				ПрочитатьФайл( цЭлемент.Значение );
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ВыполнитьПодстановки()
	
	количествоПопыток = 10;
	количествоЭлементовСПодстановкой = мПрочитанныеПараметры.Количество();

	Для ц = 1 По количествоПопыток Цикл

		текЭлементовСПодстановкой = 0;

		Для каждого цЭлемент Из мПрочитанныеПараметры Цикл

			Если ТипЗнч( цЭлемент.Значение ) = Тип( "Строка")
				И СтрНайти( цЭлемент.Значение, "%" ) > 0 Тогда
				текЭлементовСПодстановкой = текЭлементовСПодстановкой + 1;
			КонецЕсли;

		КонецЦикла;

		Если текЭлементовСПодстановкой = количествоЭлементовСПодстановкой Тогда
			Прервать;
		КонецЕсли;

		количествоЭлементовСПодстановкой = текЭлементовСПодстановкой;

		Для каждого цЭлемент Из мПрочитанныеПараметры Цикл

			ВыполнитьПодстановкуЭлементу(цЭлемент);

		КонецЦикла;

	КонецЦикла;

КонецПроцедуры

Процедура ВыполнитьПодстановкуЭлементу( пЭлемент )
	
	Если Не ТипЗнч( пЭлемент.Значение ) = Тип( "Строка") Тогда
		Возврат;		
	КонецЕсли;

	регулярноеВыражение = Новый РегулярноеВыражение( "%([^%]*)%" );

	массивСовпадений = регулярноеВыражение.НайтиСовпадения( пЭлемент.Значение );

	Для каждого цЭлемент Из массивСовпадений Цикл

		ключ = цЭлемент.Значение;

		найденноеЗначение = мПрочитанныеПараметры[ключ];

		Если Не найденноеЗначение = Неопределено Тогда
			пЭлемент.Значение = СтрЗаменить( пЭлемент.Значение, "%" + ключ + "%", найденноеЗначение );
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Функция Префикс_ПрочитатьФайл()
	Возврат "ReadFile";
КонецФункции

Функция ФайлСуществует( Знач пПутьКФайлу )
	
	файл = Новый Файл( пПутьКФайлу );
	Возврат файл.Существует() И файл.ЭтоФайл();

КонецФункции

Функция ПолучитьТекстИзФайла( Знач пИмяФайла )
	
	прочитанныйТекст = "";
	чтениеТекста = Новый ЧтениеТекста(пИмяФайла, КодировкаТекста.UTF8);
	прочитанныйТекст = чтениеТекста.Прочитать();
	чтениеТекста.Закрыть();
	возврат прочитанныйТекст;

КонецФункции