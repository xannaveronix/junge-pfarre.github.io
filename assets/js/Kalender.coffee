---
---

#Dieses Script parsed diesen Online-Kalender im Atom/XML-Format: https://posteo.de/calendars/feed/s49fo2ntyyrp1pfk1u9vq1h34ho9j93v
#und fügt es in die Webseite ein.
#Nach diesem Tutorial: https://coffeescript-cookbook.github.io/chapters/ajax/ajax_request_without_jquery (Coffeescript Cookbook)

  xhr = new XMLHttpRequest()

  xhr.addEventListener 'readystatechange', ->
    if xhr.readyState is 4                                  #ReadyState Complete
      successResultCodes = [200,304]
      if xhr.status in successResultCodes
        response = xhr.responseXML
        resolver = -> 'http://www.w3.org/2005/Atom'         #Atom namespace resolver
        calendarTitles = response.evaluate '/Atom:feed/Atom:entry/Atom:title', response, resolver, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null
        calendarDates = response.evaluate '/Atom:feed/Atom:entry/Atom:updated', response, resolver, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null
        snapshotMaxIndex = calendarTitles.snapshotLength-1
        x = [0..snapshotMaxIndex]
        events = ({title: calendarTitles.snapshotItem(i).innerHTML, date: calendarDates.snapshotItem(i).innerHTML} for i in x)        #parse all entries to json
        events.reverse()                                    #Umordnen, da Originaldaten absteigend geordnet sind
        calendarList = document.getElementById 'calendar'   #<div> mit entsprechender Id suchen
        calendarListItems = ''
        dateOptions = {weekday: "short", year: "numeric", month: "short", day: "numeric", hour: "numeric", minute: "2-digit"}
        testtime = new Date(Date.now())
        testtime.setHours(testtime.getHours() - 11)
        for event in events
          date = new Date(event.date)
          if date > testtime                                #Vergangene Events werden noch 12 Stunden (11h in MESZ) nach Event-Beginn angezeigt
            calendarListItems = calendarListItems + "<li>#{event.title} (#{date.toLocaleString([], dateOptions)})</li>"
        if calendarListItems
          calendarList.innerHTML = '<ul>' + calendarListItems + '</ul>'
        else
          calendarList.innerHTML = 'Im nächsten Monat sind keine Veranstaltungen geplant'
      else
        console.log 'Error loading data...'

  xhr.open 'GET', 'https://cors-anywhere.herokuapp.com/https://posteo.de/calendars/feed/s49fo2ntyyrp1pfk1u9vq1h34ho9j93v'
  xhr.send()
