<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2016, Web Site Management" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Find Page By Content</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<style type="text/css">
		body
		{
			padding: 10px;
		}
	</style>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/handlebars-v2.0.0.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var TreeGuid = '<%= session("treeguid") %>';
		var TemplateGuid = '';
		var ElementType = '';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);

		$(document).ready(function() {
		    $('#find-content').on('click', function() {
		        var ElementContent = $('#elt-content').val();
		        SearchContent(ElementContent);
		    });
		    GetTemplateData();
		});
	
		function GotoTreeSegment(sGuid, sType, sParentGuid)
		{
			if(top.opener.parent.frames.ioTreeData){
				// MS 10 or less
				top.opener.parent.frames.ioTreeData.document.location = '../../ioRDLevel1.asp?Action=GotoTreeSegment&Guid=' + sGuid + '&Type=' + sType + "&ParentGuid=" + sParentGuid + '&CalledFromRedDot=0';
			} else {
				// MS 11
				top.opener.parent.parent.parent.ioTreeIFrame.frames.ioTreeFrames.frames.ioTree.GotoTreeSegment(sGuid, sType, sParentGuid);
			}
		}

		function GetTemplateData()
		{
            var strRQLXML = '<TEMPLATE><ELEMENT action="load" guid="' + TreeGuid + '"/></TEMPLATE>';
            RqlConnectorObj.SendRql(strRQLXML, false, function(data) {
                TemplateGuid = $(data).find('ELEMENT').attr('templateguid');
                ElementType = $(data).find('ELEMENT').attr('elttype');
                if (ElementType == '8') {
                    $(controls).empty();
                    var Template = Handlebars.compile($('#template-optionlist').html());
                    var TemplateData = Template();
                    $(controls).append(TemplateData);
                    var Template = Handlebars.compile($('#template-optionlist-items').html());
                    var strRQLXML = '<TEMPLATE><ELEMENT action="load" guid="' + TreeGuid + '"><SELECTIONS action="list"/></ELEMENT></TEMPLATE>';
                    RqlConnectorObj.SendRql(strRQLXML, false, function(data) {
                        $(data).find('SELECTION').each(function() {
                            var OptionItems = {
                                'description': $(this).attr('description'),
                                'guid': $(this).attr('guid')
                            };
                            var TemplateData = Template(OptionItems);
                            $('#elt-content').append(TemplateData);
                        });
                    });
                }
            });
		}

		function SearchContent(ElementContent)
		{
			if(ElementContent == '')
			{
				return;
			}
			$('#find-content').prop('disabled', true);
			$(results).empty();
			$(results).append('Please wait...');
            var Template = Handlebars.compile($('#template-result').html());
            var strRQLXML = '<PAGE action="xsearch" orderby="headline" orderdirection="ASC" pagesize="500" maxhits="500"><SEARCHITEMS><SEARCHITEM key="searchtext" value="' + ElementContent + '" operator="like"/><SEARCHITEM key="contentclassguid" value="' + TemplateGuid + '" operator="eq"/></SEARCHITEMS></PAGE>';
            RqlConnectorObj.SendRql(strRQLXML, false, function (data) {
                $(results).empty();
                var counter = 0;
                $(data).find('PAGE').each(function () {
                    counter++;
		            var ContentPages = {
		                'headline': $(this).attr('headline'),
		                'guid': $(this).attr('guid'),
		                'id': $(this).attr('id'),
		                'counter': counter
		            };
		            var TemplateData = Template(ContentPages);
		            $(results).append(TemplateData);
		        });
		        $(results).append(counter + ' Results - Search finished!');
		        var ResultContainer = $('#template-result').attr('data-container');
		        $(ResultContainer).on('click', '.open-page', function() {
		            var ContentTreeGuid = $(this).attr('data-guid');
		            var ContentTreeType = $(this).attr('data-treetype');
		            GotoTreeSegment(ContentTreeGuid, ContentTreeType, '');
		        });
		        $('#find-content').prop('disabled', false);
            });
		}
		
		function TranslateElementType(ElementType)
		{
			var elttype = [];
			// Content Elements		elements
				elttype[1] 		= { type:"element", parentGuid:"elements" }; // Standard Field - Text
				elttype[5] 		= { type:"element", parentGuid:"elements" }; // Standard Field - Date
				elttype[39]		= { type:"element", parentGuid:"elements" }; // Standard Field - Time
				elttype[62]		= { type:"element", parentGuid:"elements" }; // Standard Field - Date and Time
				elttype[48]		= { type:"element", parentGuid:"elements" }; // Standard Field - Numeric
				elttype[999] 	= { type:"element", parentGuid:"elements" }; // Standard Field - User defined
				elttype[50] 	= { type:"element", parentGuid:"elements" }; // Standard Field - e-mail
				elttype[51]		= { type:"element", parentGuid:"elements" }; // Standard Field - URL
				elttype[1000]	= { type:"element", parentGuid:"elements" }; // Standard Field
				elttype[31]		= { type:"element", parentGuid:"elements" }; // Text ASCI
				elttype[32]		= { type:"element", parentGuid:"elements" }; // Text HTML
				elttype[60]		= { type:"element", parentGuid:"elements" }; // Transfer
				elttype[1005] 	= { type:"element", parentGuid:"elements" }; // Common Content Element
				elttype[1007]	= { type:"element", parentGuid:"elements" }; // Generic Element
				elttype[10] 	= { type:"element", parentGuid:"elements" }; // Content of Project 
				elttype[8] 		= { type:"element", parentGuid:"elements" }; // Option list
				elttype[38]		= { type:"element", parentGuid:"elements" }; // Media 
				elttype[25]		= { type:"element", parentGuid:"elements" }; // List entry
				elttype[2] 		= { type:"element", parentGuid:"elements" }; // Image
				elttype[12] 	= { type:"element", parentGuid:"elements" }; // Headline 
				elttype[52] 	= { type:"element", parentGuid:"elements" }; // eDocs DM Media Element 
				elttype[1004]	= { type:"element", parentGuid:"elements" }; // Delivery Server constraint 
				elttype[1006]	= { type:"element", parentGuid:"elements" }; // Delivery Server
				elttype[14]		= { type:"element", parentGuid:"elements" }; // Database Content 
				elttype[19] 	= { type:"element", parentGuid:"elements" }; // Background
			// Structure Elements	
				elttype[26]		= { type:"link", parentGuid:"" }; // Anchor as text
				elttype[27]		= { type:"link", parentGuid:"" }; // Anchor as image
				elttype[2627]	= { type:"link", parentGuid:"" }; // Anchor
				elttype[15]		= { type:"link", parentGuid:"" }; // Area
				elttype[23]		= { type:"link", parentGuid:"" }; // Browse
				elttype[28]		= { type:"link", parentGuid:"" }; // Container
				elttype[3] 		= { type:"link", parentGuid:"" }; // Frame
				elttype[13]		= { type:"link", parentGuid:"" }; // List
				elttype[99]		= { type:"link", parentGuid:"" }; // Site map
				elttype[24]		= { type:"link", parentGuid:"" }; // Hit list
			return elttype[ElementType];

        }
	</script>
	<script id="template-optionlist" type="text/x-handlebars-template" data-container="#controls" data-action="replace">
        <select id="elt-content"></select>
	</script>
	<script id="template-optionlist-items" type="text/x-handlebars-template" data-container="#optionlist" data-action="append">
        <option data-guid="{{guid}}" value="{{guid}}">{{description}}</option>
	</script>
	<script id="template-result" type="text/x-handlebars-template" data-container="#results" data-action="append">
		<div class="alert alert-info">
			<div class="btn open-page" data-guid="{{guid}}" data-treetype="page"><span title="Jump to Page" alt="Jump to Page" class="icon-eye-open"></span></div>
			<div class="btn btn-link content-page-in-tree" data-guid="{{guid}}" data-treetype="page" title="Display Content Page in Tree" alt="Display Content Page in Tree">
			    <strong style="float:left;">{{headline}}</strong><br>
			    <span style="font-size: 9px;">({{counter}} / ID: {{id}} / GUID: {{guid}})</span>
			</div>
		</div>
	</script>
</head>
<body>
	<div id="processing" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3 id="myModalLabel">Processing</h3>
		</div>
		<div class="modal-body">
			<p>Please wait...</p>
		</div>
	</div>
	<div class="container">
		<div class="navbar navbar-inverse">
			<div class="navbar-inner">
				<span class="brand">Find Page By Content</span>
			</div>
		</div>
		<div class="well">
			<div class="form-horizontal">
				<div class="control-group">
					<label class="control-label" for="inputEmail">Search for</label>
					<div class="controls" id="controls">
						<input class="input-block-level" id="elt-content" type="text" placeholder="Page Element Content">
					</div>
				</div>
				<div class="controls">
					<button class="btn btn-success" id="find-content" type="button">Search</button>
				</div>
			</div>
		</div>
		<div class="well">
			<div id="results">
			</div>
		</div>
	</div>
</body>
</html>