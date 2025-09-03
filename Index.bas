B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'Handler class
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private Method As String
	Private Elements() As String
	Private ElementKey As String
End Sub

Public Sub Initialize

End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	LogColor(Request.RequestURI, Main.COLOR_GET)
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 1) ' 1 For Index handler
	If Method <> "GET" Then
		WebApiUtils.ReturnHtmlMethodNotAllowed(Response)
		Return
	End If
	
	If ElementMatch("") Then
		ShowIndexPage
		Return
	End If
	If ElementMatch("key") Then
		Select ElementKey
			Case "update-chart"
				UpdateChartData
				Return
			Case "chart-json"
				GetChartJson
				Return
		End Select
	End If
	If ElementMatch("api/key") Then
		Select ElementKey
			Case "data"
				GetChartDataApi
				Return
			Case "random"
				GetRandomData
				Return
		End Select
	End If
	WebApiUtils.ReturnHtmlPageNotFound(Response)
End Sub

Private Sub ElementMatch (Pattern As String) As Boolean
	Select Pattern
		Case ""
			If Elements.Length = 0 Then
				Return True
			End If
		Case "key"
			If Elements.Length = 1 Then
				ElementKey = Elements(0)
				Return True
			End If
		Case "api/key"
			If Elements.Length = 2 Then
				If Elements(0) <> "api" Then Return False
				ElementKey = Elements(1)
				Return True
			End If
	End Select
	Return False
End Sub

Private Sub ShowIndexPage
	Dim content As String = File.ReadString(File.DirAssets, "index.html")
	WebApiUtils.ReturnHTML(content, Response)
End Sub

Sub UpdateChartData
	LogColor("UpdateChartData", Main.COLOR_BLUE)
    ' Generate random data
    RndSeed(DateTime.Now)
	
    Dim labels As List = Array As String("Jan", "Feb", "Mar", "Apr", "May", "Jun")
    Dim dataPoints As List
    dataPoints.Initialize
    For i = 0 To labels.Size - 1
        dataPoints.Add(Rnd(20, 100))
    Next
    
    ' Create JavaScript response
    Dim js As String = $"<script>
    if (window.myChart) {
        window.myChart.data = {
            labels: ${ToJsonArray(labels)},
            datasets: [{
                label: 'Sales Data',
                data: ${ToJsonArray(dataPoints)},
                backgroundColor: 'rgba(54, 162, 235, 0.2)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 2,
                tension: 0.3
            }]
        };
        window.myChart.update();
        showNotification('Chart updated via JS response!');
    }
    </script>"$
	Response.ContentType = WebApiUtils.CONTENT_TYPE_HTML
	Response.Write(js)
End Sub

Sub GetChartJson
	LogColor("GetChartJson", Main.COLOR_BLUE)
	' Generate random data
    RndSeed(DateTime.Now)
	
    Dim ChartData As Map = CreateMap( _
        "labels": Array As String("Q1", "Q2", "Q3", "Q4"), _
        "datasets": Array As Map(CreateMap( _
            "label": "Revenue", _
            "data": Array As Int(Rnd(1000, 5000), Rnd(1000, 5000), Rnd(1000, 5000), Rnd(1000, 5000)), _
            "backgroundColor": "rgba(153, 102, 255, 0.2)", _
            "borderColor": "rgba(153, 102, 255, 1)", _
            "borderWidth": 2, _
            "type": "bar" _
        )) _
    )
	Dim json As String = ChartData.As(JSON).ToString
	Log(json)
    Response.ContentType = WebApiUtils.CONTENT_TYPE_JSON
    Response.Write(json)
End Sub

Sub GetChartDataApi
	LogColor("GetChartDataApi", Main.COLOR_BLUE)
	' Generate random data
    RndSeed(DateTime.Now)
	
    Dim ApiData As Map = CreateMap( _
        "success": True, _
        "timestamp": DateTime.Now, _
        "data": CreateMap( _
            "labels": Array As String("Monday", "Tuesday", "Wednesday", "Thursday", "Friday"), _
            "datasets": Array As Map( _
                CreateMap( _
                    "label": "Website Visits", _
                    "data": Array As Int(Rnd(150, 300), Rnd(150, 300), Rnd(150, 300), Rnd(150, 300), Rnd(150, 300)), _
                    "borderColor": "rgba(255, 99, 132, 1)", _
                    "backgroundColor": "rgba(255, 99, 132, 0.2)", _
                    "type": "line" _
                ), _
                CreateMap( _
                    "label": "Conversions", _
                    "data": Array As Int(Rnd(20, 80), Rnd(20, 80), Rnd(20, 80), Rnd(20, 80), Rnd(20, 80)), _
                    "borderColor": "rgba(75, 192, 192, 1)", _
                    "backgroundColor": "rgba(75, 192, 192, 0.2)", _
                    "type": "line" _
                ) _
            ) _
        ) _
    )
	Dim json As String = ApiData.As(JSON).ToString
	Log(json)
    Response.ContentType = WebApiUtils.CONTENT_TYPE_JSON
    Response.Write(json)
End Sub

Sub GetRandomData
	LogColor("GetRandomData", Main.COLOR_BLUE)
    ' Generate random data
	RndSeed(DateTime.Now)
	
    Dim chartType As String = IIf(Request.ParameterMap.ContainsKey("type"), Request.GetParameter("type"), "bar")
    Dim dataPoints As Int = IIf(Request.ParameterMap.ContainsKey("points"), Request.GetParameter("points"), 6)
    
    If dataPoints > 12 Then dataPoints = 12
    If dataPoints < 3 Then dataPoints = 3

    
	
    Dim labels As List
    labels.Initialize
    Dim data As List
    data.Initialize
    
    For i = 1 To dataPoints
        labels.Add($"Day ${i}"$)
        data.Add(Rnd(10, 100))
    Next
    
    Dim RandomData As Map = CreateMap( _
        "data": CreateMap( _
            "labels": labels, _
            "datasets": Array As Map(CreateMap( _
                "label": "Random Data", _
				"type": chartType, _
                "data": data, _
                "backgroundColor": GetRandomColor, _
                "borderColor": GetRandomColor, _
                "borderWidth": 2 _
            )) _
        ) _
    )
	Response.ContentType = WebApiUtils.CONTENT_TYPE_JSON
	Response.Write(RandomData.As(JSON).ToString)
End Sub

Sub GetRandomColor As String
	RndSeed(DateTime.Now)
    Dim colors As List = Array As String( _
        "rgba(255, 99, 132, ", "rgba(54, 162, 235, ", "rgba(255, 206, 86, ", _
        "rgba(75, 192, 192, ", "rgba(153, 102, 255, ", "rgba(255, 159, 64, " _
    )
    Dim color As String = colors.Get(Rnd(0, colors.Size))
    Return color & "1)" ' Solid color for border
End Sub

' Helper function to convert List to JSON array
Sub ToJsonArray (list As List) As String
	Return list.As(JSON).ToCompactString
End Sub