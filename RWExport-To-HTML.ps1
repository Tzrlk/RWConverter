

param (
    # Source file path and name.
    [Parameter(Mandatory,Position=1)] 
    [string]$Source,

    # Destination file path and name.
    [Parameter(Mandatory,Position=2)] 
    [string]$Destination,

    # Sort topics by:
    #    1 = Name
    #    2 = Prefix, Name **Default**
    #    3 = Category, Name
    #    4 = Category, Prefix, Name
    #
    # Choosing options 2 or 4 will sort by prefix, regardless of whether or not
    #    the -Prefix switch is specified. Likewise, choosing options 1 or 3 will
    #    sort by name, regardless of whether or not the -Prefix switch is specified.
    [Parameter()] 
    [int]$Sort = 2,

    # Include prefix in topic name ($true or $false)
    [switch]$Prefix,

    # Include suffix in topic name ($true or $false)
    [switch]$Suffix,

    # Include topic details (Category, Parent, Linkage, Tags, etc ...)
    [switch]$Details,

    # Indent nested topics and sections.
    [switch]$Indent,

    # Include a separator line between snippets.
    [switch]$SeparateSnippets,

    # Display Statblocks inline.
    [switch]$InlineStats,

    # Scale percentage for displaying Simple Pictures inline.
    #    Omitting this parameter, or setting it to 0
    #    will display thumbnails.
    [Parameter()] 
    [int]$SimpleImageScale = 0,

    # Scale percentage for displaying Smart Images inline.
    #    Omitting this parameter, or setting it to 0
    #    will display thumbnails.
    [Parameter()] 
    [int]$SmartImageScale = 0,

    # Specify the path for an optional log file.
    #    [NOT WORKING YET]
    [Parameter()] 
    [string]$Log

) # param

Function ParseTopic($PassedTopic,$Outputfile,$Sort,$Prefix,$Suffix,$Details,$Indent,$SeparateSnippets,$InlineStats,$SimpleImageScale,$SmartImageScale,$Parent,$TitleCSS,$TopicCSS,$TopicDetailsCSS,$SectionCSS,$SnippetCSS,$Indcrement,$Log) {
   $TopicName = $PassedTopic.public_name
   if ($Prefix -and $PassedTopic.Prefix) {$TopicName = $PassedTopic.Prefix + " - " + $TopicName}
   if ($Suffix -and $PassedTopic.Suffix) {$TopicName = $TopicName + " (" + $PassedTopic.Suffix + ")"}
  
   $ParentName = "Parent Topic: $Parent"
   $CategoryName = "Category: " + $PassedTopic.category_name.Trim()
   $TopicDetails = "$ParentName<br>$CategoryName"

   If ($PassedTopic.tag_assign) {
      $tagline = ParseTags $PassedTopic $Outputfile $Log
      $TopicDetails = "$TopicDetails<br>$tagline"
   } # If ($PassedTopic.tag_assign)

   If ($PassedTopic.linkage) {
      $linkage = ParseLinkage $PassedTopic $outputfile $Log
      $TopicDetails = "$TopicDetails<br>$linkage"
   } # If ($PassedTopic.linkage)

   $TopicName = $TopicCSS.Replace("*",$TopicName)
   $TopicDetails = $TopicDetailsCSS.Replace("*",$TopicDetails)

   [System.IO.File]::AppendAllText($outputfile,$TopicName)
   If ($Details) {[System.IO.File]::AppendAllText($outputfile,$TopicDetails)}

   foreach ($Section in $PassedTopic.section) {
      ParseSection $Section $Outputfile $SectionCSS $SnippetCSS $Indcrement $SeparateSnippets $InlineStats $SimpleImageScale $SmartImageScale $Log
   } # foreach ($Section in $PassedTopic.section)

   Switch ($Sort) {
      1 {$TopicList = $PassedTopic.topic | Sort-Object public_name}
      2 {$TopicList = $PassedTopic.topic | Sort-Object prefix,public_name}
      3 {$TopicList = $PassedTopic.topic | Sort-Object category_name,public_name}
      4 {$TopicList = $PassedTopic.topic | Sort-Object category_name,prefix,public_name}
      default {$TopicList = $PassedTopic.topic}
   }

   $Parent = $Parent + $PassedTopic.Public_Name + "/"
   foreach ($Topic in $TopicList) {
      If ($Indent) {
         $SubTopicCSS = AddIndent $TopicCSS $Indcrement $Log
         $SubTopicDetailsCSS = AddIndent $TopicDetailsCSS $Indcrement $Log
         $SubSectionCSS = AddIndent $SectionCSS $Indcrement $Log
         $SubSnippetCSS = AddIndent $SnippetCSS $Indcrement $Log
      } else {
         $SubTopicCSS = $TopicCSS
         $SubTopicDetailsCSS = $TopicDetailsCSS
         $SubSectionCSS = $SectionCSS
         $SubSnippetCSS = $SnippetCSS
      } # If ($Indent)
      ParseTopic $Topic $Outputfile $Sort $Prefix $Suffix $Details $Indent $SeparateSnippets $InlineStats $SimpleImageScale $SmartImageScale $Parent $TitleCSS $SubTopicCSS $SubTopicDetailsCSS $SubSectionCSS $SubSnippetCSS $Indcrement $Log
   } # foreach ($Topic in $TopicList)
} # Function ParseTopic($PassedTopic)

Function ParseSection ($PassedSection,$Outputfile,$SectionCSS,$SnippetCSS,$Indcrement,$SeparateSnippets,$InlineStats,$SimpleImageScale,$SmartImageScale,$Log) {
   $SectionName = $SectionCSS.Replace("*",$PassedSection.name)

   [System.IO.File]::AppendAllText($outputfile,$sectionname)
   # Add-Content -Path $outputfile -Value $SectionName

   foreach ($Snippet in $PassedSection.snippet) {
      ParseSnippet $Snippet $Outputfile $SnippetCSS $Indcrement $SeparateSnippets $InlineStats $SimpleImageScale $SmartImageScale $Log
   } # foreach ($Snippet in $PassedSection.snippet)

   foreach ($Section in $PassedSection.section) {
      If ($Indent) {
         $SubSectionCSS = AddIndent $SectionCSS $Indcrement $Log
         $SubSnippetCSS = AddIndent $SnippetCSS $Indcrement $Log
      } else {
         $SubSectionCSS = $SectionCSS
         $SubSnippetCSS = $SnippetCSS
      } # If ($Indent)
      ParseSection $Section $Outputfile $SubSectionCSS $SubSnippetCSS $Indcrement $SeparateSnippets $InlineStats $SimpleImageScale $SmartImageScale $Log
   } # foreach ($Section in $PassedSection.section)
} # Function ParseSection ($PassedSection)

Function ParseSnippet ($PassedSnippet,$Outputfile,$SnippetCSS,$Indcrement,$SeparateSnippets,$InlineStats,$SimpleImageScale,$SmartImageScale,$Log) {
   switch ($PassedSnippet.type) { 
      "Audio" {
         $Type = "Audio File"
         $Name = $PassedSnippet.ext_object.name
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Name + ": [$Type, no preview available]<BR>$annotation"

         $Text = $Text.Trim()
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$text)
         # Add-Content -Path $outputfile -Value $Text
      } # "Audio"

      "Date_Game" {
         if ($PassedSnippet.Label -ne $null) {
            if ($PassedSnippet.Label.endswith(':')) {$LabelPrefix = $PassedSnippet.Label + ' '} else {$LabelPrefix = $PassedSnippet.Label + ': '}
         } # if ($PassedSnippet.Label -ne $null)
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $Text = $LabelPrefix + $PassedSnippet.game_date.display
         $Text = $Text + "<br>Annotation: $annotation"
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.Replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # Date_Game

      "Date_Range" {
         if ($PassedSnippet.Label -ne $null) {
            if ($PassedSnippet.Label.endswith(':')) {$LabelPrefix = $PassedSnippet.Label + ' '} else {$LabelPrefix = $PassedSnippet.Label + ': '}
         } # if ($PassedSnippet.Label -ne $null)
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $Text = $LabelPrefix + $PassedSnippet.date_range.display_start + " to " + $PassedSnippet.date_range.display_end
         $Text = $Text + "<br>Annotation: $annotation"
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.Replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # Date_Range

      "Foreign" {
         $Type = "Foreign Object"
         $Name = $PassedSnippet.ext_object.name
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Name + ": [$Type, no preview available]<BR>$annotation"

         $Text = $Text.Trim()
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "Foreign"

      "HTML" {
         $Type = "HTML Page (Complete)"
         $Name = $PassedSnippet.ext_object.name
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Name + ": [$Type, no preview available]<BR>$annotation"

         $Text = $Text.Trim()
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "HTML"

      "Labeled_Text" {
         $Text = $PassedSnippet.contents
         $TagPreface = '<span class="RWSnippet">'
         if ($PassedSnippet.Label -ne $null) {
            if ($PassedSnippet.Label.endswith(':')) {$LabelPrefix = $PassedSnippet.Label + ' '} else {$LabelPrefix = $PassedSnippet.Label + ': '}
         } # if ($PassedSnippet.Label -ne $null)
         $InsertPoint = $Text.IndexOf($TagPreface) + $TagPreface.Length
         $Text = $Text.insert($InsertPoint,$LabelPrefix)
         $Text = InsertMargin $Text $SnippetCSS $Log
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "Labeled_Text"

      "Multi_Line" {
        if ($PassedSnippet.purpose -eq "directions_only") {
           $Text = $PassedSnippet.gm_directions
           $TagPreface = '<span class="RWSnippet">'
           $LabelPrefix = 'GM Directions: '
           $InsertPoint = $Text.IndexOf($TagPreface) + $TagPreface.Length
           $Text = $Text.insert($InsertPoint,$LabelPrefix)
           $Text = InsertMargin $Text $SnippetCSS $Log
           if ($SeparateSnippets) {$Text = $Text + "<hr>"}
           [System.IO.File]::AppendAllText($outputfile,$Text)
           # Add-Content -Path $Outputfile -Value $Text
        } elseif ($PassedSnippet.purpose -eq "Both") {
           if ($PassedSnippet.gm_directions -ne $null) {
              $Text = $PassedSnippet.gm_directions
              $TagPreface = '<span class="RWSnippet">'
              $LabelPrefix = 'GM Directions: '
              $InsertPoint = $Text.IndexOf($TagPreface) + $TagPreface.Length
              $Text = $Text.insert($InsertPoint,$LabelPrefix)
              $Text = InsertMargin $Text $SnippetCSS $Log
              if ($SeparateSnippets) {$Text = $Text + "<hr>"}
              [System.IO.File]::AppendAllText($outputfile,$Text)
              # Add-Content -Path $outputfile -Value $Text
           } # if ($PassedSnippet.gm_directions -ne $null)

           if ($PassedSnippet.contents -ne $null) {
              $Text = InsertMargin $PassedSnippet.contents $SnippetCSS $Log
              if ($SeparateSnippets) {$Text = $Text + "<hr>"}
              [System.IO.File]::AppendAllText($outputfile,$Text)
              # Add-Content -Path $outputfile -Value $Text
           } # if ($PassedSnippet.contents -ne $null)

        } elseif (($PassedSnippet.contents -ne $null) -and (($PassedSnippet.contents.contains("<ul")) -or ($PassedSnippet.contents.contains("<ol")) -or ($PassedSnippet.contents.contains("<table")))) {
           $TagList = GetTagLocations $PassedSnippet.contents $Log
           $Text = InsertFormattedMargins $PassedSnippet.contents $SnippetCSS $TagList $Log
           if ($SeparateSnippets) {$Text = $Text + "<hr>"}
           # $Text = InsertMargin $PassedSnippet.contents $SnippetCSS
           [System.IO.File]::AppendAllText($outputfile,$Text)
           # Add-Content -Path $outputfile -Value $Text
        } else {
           $Text = InsertMargin $PassedSnippet.contents $SnippetCSS $Log
           if ($SeparateSnippets) {$Text = $Text + "<hr>"}
           [System.IO.File]::AppendAllText($outputfile,$Text)
           # Add-Content -Path $outputfile -Value $Text
        } # if ($PassedSnippet.purpose -eq "directions_only")
      } # "Multi_Line"

      "Numeric" {
         $Text = $PassedSnippet.contents
         if ($PassedSnippet.Label -ne $null) {
            if ($PassedSnippet.Label.endswith(':')) {$LabelPrefix = $PassedSnippet.Label + ' '} else {$LabelPrefix = $PassedSnippet.Label + ': '}
         } # if ($PassedSnippet.Label -ne $null)
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $Text = $LabelPrefix + $Text + "<br>Annotation: $annotation"
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.Replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "Numeric"

      "PDF" {
         $Type = "PDF Document"
         $Name = $PassedSnippet.ext_object.name
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Name + ": [$Type, no preview available]<BR>$annotation"

         $Text = $Text.Trim()
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "PDF"

      "Picture" {
         $FullImage = $PassedSnippet.ext_object.asset.contents
         $ImageLink = '<a href="data:image/png;base64,' + $FullImage + '">Picture</a>'
         $ImageName = $PassedSnippet.ext_object.name
         $Text = $ImageName + ": [$ImageLink]"
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Text + "<BR>$annotation"
         $Text = $SnippetCSS.replace("*",$Text)

         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $Outputfile -Value $Text

         If ($SimpleImageScale -eq 0) {
            $Thumbnail = $PassedSnippet.ext_object.asset.thumbnail
            $EncodedImage = '<img src="data:image/png;base64,' + $Thumbnail + '">'
         } else {
            $SimpleImageScale = $SimpleImageScale / 100
            $SimpleImageScale = 'style="transform:scale(' + $SimpleImageScale + ');"'
            $EncodedImage = '<img ' + $SimpleImageSCale + ' src="data:image/png;base64,' + $FullImage + '">'
         }
         $tag = "<img "
         $EncodedImage = InsertMiscMargins $EncodedImage $SnippetCSS $tag $Log
         if ($SeparateSnippets) {$EncodedImage = $EncodedImage + "<hr>"}
         [System.IO.File]::AppendAllText($outputfile,$EncodedImage)
         # Add-Content -Path $outputfile -Value $EncodedImage
      } # "Picture"

      "Portfolio" {
         $Statblock = "Hero Lab Portfolio"
         $Name = $PassedSnippet.ext_object.name
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Name + ": [$Statblock, no preview available]<BR>$annotation"
         $Text = $Text.Trim()
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Stats = $SnippetCSS.replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Stats)
         # Add-Content -Path $outputfile -Value $Stats
      } # "Portfolio"

      "Rich_Text" {
         $Type = "Rich Text Document"
         $Name = $PassedSnippet.ext_object.name
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Name + ": [$Type, no preview available]<BR>$annotation"

         $Text = $Text.Trim()
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "Rich Text"

      "Smart_Image" {
         $FullImage = $PassedSnippet.smart_image.asset.contents
         $ImageLink = '<a href="data:image/png;base64,' + $FullImage + '">Smart Image</a>'
         $ImageName = $PassedSnippet.smart_image.name
         $Text = $ImageName + ": [$ImageLink]"
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Text + "<BR>$annotation"
         $Text = $SnippetCSS.replace("*",$Text)

         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $Outputfile -Value $Text

         If ($SmartImageScale -eq 0) {
            $Thumbnail = $PassedSnippet.smart_image.asset.thumbnail
            $EncodedImage = '<img src="data:image/png;base64,' + $Thumbnail + '">'
         } else {
            $SmartImageScale = $SmartImageScale / 100
            $SmartImageScale = 'style="transform:scale(' + $SmartImageScale + ');"'
            $EncodedImage = '<img ' + $SmartImageSCale + ' src="data:image/png;base64,' + $FullImage + '">'
         }
         $tag = "<img "
         $EncodedImage = InsertMiscMargins $EncodedImage $SnippetCSS $tag $Log
         If ($SeparateSnippets) {$EncodedImage = $EncodedImage + "<hr>"}
         [System.IO.File]::AppendAllText($outputfile,$EncodedImage)
         # Add-Content -Path $outputfile -Value $EncodedImage
      } # "Smart_Image"

      "Statblock" {
         $Statblock = "Stat Block"
         $Name = $PassedSnippet.ext_object.name
         $EncodedStats = $PassedSnippet.ext_object.asset.contents
         $Stats = '<a href="data:text/html;base64,' + $EncodedStats + '">' + $Statblock + '</a>'
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Name + ": [$Stats]<BR>$annotation"

         $Text = $Text.Trim()
         If ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Stats = $SnippetCSS.replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Stats)
         # Add-Content -Path $outputfile -Value $Stats

         if ($InlineStats) {
            $DecodedStats = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($EncodedStats));
            $PTag = $DecodedStats.IndexOf("<p ")
            $BodyTag = $DecodedStats.IndexOf("</body>")
            $SubStringStart = $PTag
            $SubStringLength = $BodyTag - $PTag

            $Body = $DecodedStats.substring($SubStringStart,$SubStringLength)
            $Body = $Body.replace("RWLink","StatBlockLink")
            $Body = $Body.replace("RWSnippet","StatBlockSnippet")
            $Body = $Body.replace("RWDefault","StatBlockDefault")
            $Body = $Body.replace("RWBullet","StatBlockBullet")
            $Body = $Body.replace("RWEnumerated","StatBlockEnumerated")

            $Body = $Body.replace(".td",".StatBlock-td")
            $Body = $Body.replace(".tr","StatBlock-tr")
            $Body = $Body.replace(".p","StatBlock-p")


            if ($SeparateSnippets) {$Body = $Body + "<hr>"}
            [System.IO.File]::AppendAllText($outputfile,$Body)
            # Add-Content -Path $outputfile -Value $Body
         } # if ($InlineStats)

      } # "Statblock"

      "Tag_Multi_Domain" {
         $Text = ParseTags $PassedSnippet $Log
         $Text = $SnippetCSS.Replace("*",$Text)
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "Tag_Multi_Domain"

      "Tag_Standard" {
         $Text = ParseTags $PassedSnippet $Log
         $Text = $SnippetCSS.Replace("*",$Text)
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "Tag_Standard"

      "Video" {
         $Type = "Video File"
         $Name = $PassedSnippet.ext_object.name
         $annotation = ParseSnippetText $PassedSnippet.annotation $Log
         $annotation = "Annotation: " + $annotation
         $Text = $Name + ": [$Type, no preview available]<BR>$annotation"

         $Text = $Text.Trim()
         if ($SeparateSnippets) {$Text = $Text + "<hr>"}
         $Text = $SnippetCSS.replace("*",$Text)
         [System.IO.File]::AppendAllText($outputfile,$Text)
         # Add-Content -Path $outputfile -Value $Text
      } # "Video"

      default {
         # Do nothing here.
      } # default
   } # switch ($PassedSnippet.type)
} # Function ParseSnippet

Function ParseSnippetText ($PassedText,$Log) {
   if ($PassedText -ne $null) {
      $gt = $PassedText.Indexof('>')
   } else {
      $gt = -1
   } # if ($PassedText -ne $null)
   $Text = $null
   While ($gt -ge 0) {
      # $gt = $PassedText.Indexof(">",$RWSnippet)
      $lt = $PassedText.Indexof("<",$gt)
      $length = $lt-$gt
      if ($length -gt 1) {$Text = $Text + $PassedText.substring($gt+1,$length-1)}
      if ($lt -lt $gt) {
         $gt = -1
      } else {
         $PassedText = $PassedText.substring($lt,$PassedText.length-$lt)
         $gt = $PassedText.Indexof('>')
      } # if ($lt -lt $gt)
   } # While ($gt -ge 0)
   # if ($Text.contains("&nbsp;")) {$Text = $Text.replace("&nbsp;","`r`n`r`n")}
   Return $Text
} # Function ParseSnippetText

Function ParseTags ($PassedTags,$Log) {
   # This block of code assumes that tags of the same domain will always be grouped together.
   $domain = 0
   $tagdomains = $PassedTags.tag_assign.domain_name
   if ($tagdomains.count -gt 1) {
      $tagdomain = $tagdomains[$domain]
   } else {
      $tagdomain = $tagdomains
   }
   $tagline = ""

   foreach ($tag in $PassedTags.tag_assign) {
      if ($tag.domain_name -eq $tagdomain) {
         if ($tagline -eq "") {$tagline = $tagdomain + ": " + $tag.tag_name} else {$tagline = $tagline + ", " + $tag.tag_name}
         $domain++
      } else {
         $tagdomain = $tag.domain_name
         $tagline = $tagline + "<br>" + $tagdomain + ": " + $tag.tag_name
         $domain++
      } # if ($tag.domain_name -eq $tagdomain)
   } # foreach ($tag in $PassedSnippet.tag_assign)

   if ($PassedTags.annotation) {
      $annotation = ParseSnippetText $PassedTags.annotation $Log
      $tagline = "$tagline<br>Annotation: $annotation"
   } # if ($PassedTags.annotation)

   if ($PassedTags.label) {
      if ($PassedSnippet.Label -ne $null) {
            if ($PassedSnippet.Label.endswith(':')) {$LabelPrefix = $PassedSnippet.Label + ' '} else {$LabelPrefix = $PassedSnippet.Label + ': '}
         } # if ($PassedSnippet.Label -ne $null)
      $tagline = $LabelPrefix + "<br>" + $tagline
   } # if ($PassedTags.label)

   Return $tagline.trim()
} # Function ParseTags

Function ParseLinkage ($PassedTopic,$OutputFile,$Log) {
   $Linkage = $PassedTopic.linkage
   $LinkList = ""
   foreach ($link in $linkage) {
      if ($linklist -eq "") {$linklist = "Linkage: " + $link.target_name} else {$linklist = $linklist + ", " + $link.target_name}
   } # foreach ($link in $linkage)
   Return $Linklist
} # Function ParseLinkage

Function GetTagLocations ($PassedSnippet,$Log) {
   $taglist = $null
   # Get the locations of all the start tags.
   $ul = $PassedSnippet.IndexOf("<ul")
   $ol = $PassedSnippet.IndexOf("<ol")
   $table = $PassedSnippet.IndexOf("<table")

   While (($ul -ge 0) -or ($ol -ge 0) -or ($table -ge 0)) {
      if ($ul -ge 0) {
         $properties = @{
            'Tag'='ul';
            'Start'=$ul;
            'End'=0
         } # $properties

         $TagLocation = New-Object –TypeName PSObject –Prop $properties
         [array]$Taglist = $Taglist + $TagLocation
      } # if ($ul -ge 0)

      if ($ol -ge 0) {
         $properties = @{
            'Tag'='ol';
            'Start'=$ol;
            'End'=0
         } # $properties

         $TagLocation = New-Object –TypeName PSObject –Prop $properties
         [array]$Taglist = $Taglist + $TagLocation
      } # if ($ol -ge 0)

      if ($table -ge 0) {
         $properties = @{
            'Tag'='table';
            'Start'=$table;
            'End'=0
         } # $properties

         $TagLocation = New-Object –TypeName PSObject –Prop $properties
         [array]$Taglist = $Taglist + $TagLocation
      } # if ($table -ge 0)

      $Taglist = $Taglist | Sort-Object Start
      $HighTag = $Taglist.Count-1
      $StartPosition = $Taglist[$HighTag].Start + 1

      $ul = $PassedSnippet.IndexOf("<ul",$StartPosition)
      $ol = $PassedSnippet.IndexOf("<ol",$StartPosition)
      $table = $PassedSnippet.IndexOf("<table",$StartPosition)
   } # While (($ul -ge 0) -or ($ol -ge 0) -or ($table -ge 0))

   # Get all the end tags.
   foreach ($tag in $Taglist) {
      $endtag = "</" + $tag.tag + ">"
      $endtag = $PassedSnippet.IndexOf($endtag,$tag.Start + 1)
      $Tag.end = $endtag + $endtag.length-1
   } # foreach ($tag in $Taglist)

   # Fill in the gaps, if there are any.
   $firstitem = 0
   $firstpos = 0
   $lastitem = $Taglist.count -1
   for ($item=$firstitem; $item -le $lastitem; $item++) {
      if (($firstpos -lt $Taglist[$item].start)) {
         $endpos = $Taglist[$item].start - 1

         $properties = @{
            'Tag'='text';
            'Start'=$firstpos;
            'End'=$endpos
         } # $properties

         $TagLocation = New-Object –TypeName PSObject –Prop $properties
         [array]$gaplist = $gaplist + $TagLocation

      } # if (($firstpos -lt $Taglist[$item].start))

      if ($item -eq $lastitem) {
         $firstpos = $Taglist[$item].end + 1
         $endpos = $PassedSnippet.length - 1

         $properties = @{
            'Tag'='text';
            'Start'=$firstpos;
            'End'=$endpos
         } # $properties

         $TagLocation = New-Object –TypeName PSObject –Prop $properties
         [array]$gaplist = $gaplist + $TagLocation
      } # if ($item -eq $lastitem)
      $firstpos = $taglist[$item].end+1
   } # for ($item=$firstitem; $item -le $lastitem; $item++)

   $Taglist = $Taglist + $gaplist
   $Taglist = $Taglist | Sort-Object start
   Return $Taglist
} # GetTagLocations

Function InsertFormattedMargins ($PassedSnippet,$CSSCode,$TagLocations,$Log) {
   $FirstMargin = $CSSCode.IndexOf('s')
   $LastMargin = $CSSCode.IndexOf('>')
   $Length = $LastMargin-$FirstMargin
   $MarginString = $CSSCode.substring($FirstMargin,$Length)
   $MarginString = $MarginString + " "

   $Text = ""
   foreach ($tag in $TagLocations) {
      $tagtext = $PassedSnippet.substring($tag.start,$tag.end-$tag.start+1)
      Switch ($tag.tag) {
         "text" {
            $Text = $Text + $tagtext.replace('<p ',"<p $MarginString")
         } # "text"
            
         "ul" {
            $Text = $Text + $tagtext.replace('<ul ',"<ul $MarginString")
         } # "ul"

         "ol" {
            $Text = $Text + $tagtext.replace('<ol ',"<ol $MarginString")
         } # "ol"

         "table" {
            $Text = $Text + $tagtext.replace('<table ',"<table $MarginString")
            # $Text = $Text + $Text.replace('<p ',"<p $MarginString")
         } # "table"

      } # Switch ($tag.tag)
   } # foreach ($tag in $TagLocations)
   Return $Text
} # Function InsertFormattedMargins

Function InsertMiscMargins ($PassedSnippet,$CSSCode,$Tag,$Log) {
   $FirstMargin = $CSSCode.IndexOf('s')
   $LastMargin = $CSSCode.IndexOf('>')
   $Length = $LastMargin-$FirstMargin
   $MarginString = $CSSCode.substring($FirstMargin,$Length)
   $MarginString = $MarginString + " "
   $MarginString = $Tag + $MarginString
   $Text = $PassedSnippet.replace($tag,$MarginString)

   Return $Text
} # Function InsertMiscMargins

Function AddIndent ($CSSCode,$Indcrement,$Log) {
   $FirstString = 'style="margin-left:'
   $LastString = 'px;"'
   $FirstIndex = $CSSCode.IndexOf($FirstString)
   $LastIndex = $CSSCode.IndexOf($LastString,$FirstIndex)

   $FirstMargin = $FirstIndex + $FirstString.Length
   $Length = $LastIndex - $FirstMargin

   $CurrentMargin = $CSSCode.substring($FirstMargin,$Length)
   $NewMargin = $CurrentMargin.ToInt32($null) + $Indcrement
   $NewMargin = $NewMargin.ToString()
   $NewMargin = $FirstString + $NewMargin + $LastString

   $LastIndex = $LastIndex + $LastString.Length
   $Length = $LastIndex-$FirstIndex
   $OldMargin = $CSSCode.substring($FirstIndex,$Length)

   $NewCSS = $CSSCode.replace($OldMargin,$NewMargin)

   Return $NewCSS

} # Function AddIndent

Function InsertMargin ($PassedSnippet,$CSSCode,$Log) {
   $FirstMargin = $CSSCode.IndexOf('s')
   $LastMargin = $CSSCode.IndexOf('>')
   $Length = $LastMargin-$FirstMargin
   $MarginString = $CSSCode.substring($FirstMargin,$Length)
   $MarginString = $MarginString + " "
   $PassedSnippet = $PassedSnippet.replace('<p ',"<p $MarginString")

   Return $PassedSnippet
} # Function InsertMargin

# Just leaving this bit here for later reference as I implement logging
# $ErrorActionPreference = 'Stop'
#
# Try {
#    
# } Catch {
#     $ErrorMessage = $_.Exception.Message
#     $FailedItem = $_.Exception.ItemName
# ------------------------
# $e = $_.Exception
  #       $line = $_.InvocationInfo.ScriptLineNumber
    #     $msg = $e.Message 
# } Finally {
#     
#     $Time=Get-Date
#     "This script made a read attempt at $Time" | out-file c:\logs\ExpensesScript.log -append
# } # Try

Function ReportException ($CommandLine,$ErrorMsg,$ErrorObject) {
   Write-Host "[ERROR]"
   Write-Host
   Write-Host "   $CommandLine"
   Write-Host
   Write-Host "      Error: $ErrorMsg"
   Write-Host "     Reason:" $ErrorObject.CategoryInfo.Category " - " $ErrorObject.ToString()
   Write-Host "   Location: Line" $ErrorObject.InvocationInfo.ScriptLineNumber ", Character" $ErrorObject.InvocationInfo.OffsetInLine
   Write-Host "       Line:" $ErrorObject.InvocationInfo.Line.Trim()
   Write-Host "[/ERROR]"
   # Write-Host
   # Read-Host 'Press Enter to continue…' | Out-Null
   Exit
} # Function FileException

# Main {
   $Date = Get-Date

   # Get the command line, including all options used, for logging and error trapping.
   $CommandLine = $PSCmdlet.MyInvocation.Line

   # Setup CSS tags so all we have to do later is a string.replace of "*"
   #    with whatever text we wish to use. Also, the variable names will
   #    remind us which tags are for which elements.
   $TitleCSS = "<h1>*</h1>"
   $TopicCSS = '<h2 style="margin-left:5px;">*</h2>'
   $TopicDetailsCSS = '<h3 style="margin-left:5px;">*</h3>'
   $SectionCSS = '<h4 style="margin-left:5px;">*</h4>'
   $SnippetCSS = '<p style="margin-left:5px;">*</p>'
   $Indcrement = 50

   # Set all errors as terminating errors to facilitate error trapping.
   $ErrorActionPreference = "Stop"

   # Make sure the value specified for -Sort is valid.
   # If the value is invalid, write to the console and exit.
   if (($Sort -lt 1) -or ($Sort -gt 4)) {
      Write-Host "[ERROR]"
      Write-Host "   Invalid Sort value."
      Write-Host
      Write-Host "   Valid options are:"
      Write-Host "   1 = Sort by topic names"
      Write-Host "   2 = Sort by topic prefixes first, then by topic names (this is the default value)"
      Write-Host "   3 = Sort by topic category first, then by topic name"
      Write-Host "   4 = Sort by topic category first, then by topic prefix, then by topic name"
      Write-Host "[/ERROR]"
      # Write-Host
      # Read-Host 'Press Enter to continue…' | Out-Null
      Exit
   } # if (($Sort -lt 1) -or ($Sort -gt 4))

   # Make sure the values specified for -SimpleImageScale and -SmartImageScale are valid.
   # If either one is invalid, write to the console and exit.
   if (($SimpleImageScale -lt 0) -or ($SimpleImageScale -gt 100) -or ($SmartImageScale -lt 0) -or ($SmartImageScale -gt 100)) {
      Write-Host "[ERROR]"
      Write-Host "   Woah!!!"
      Write-Host
      Write-Host "   Valid options are:"
      Write-Host "   1 = Sort by topic names"
      Write-Host "   2 = Sort by topic prefixes first, then by topic names (this is the default value)"
      Write-Host "   3 = Sort by topic category first, then by topic name"
      Write-Host "   4 = Sort by topic category first, then by topic prefix, then by topic name"
      Write-Host "[/ERROR]"
      # Write-Host
      # Read-Host 'Press Enter to continue…' | Out-Null
      Exit
   } # if (($Sort -lt 1) -or ($Sort -gt 4))

   # If the -Log option was invoked, log the current date and the full command line.
   # If anything goes wrong with this, write the error to the console and exit.
   if ($Log) {
      Try {
        [System.IO.File]::WriteAllText($Log,$Date)
        [System.IO.File]::AppendAllText($Log,$CommandLine)
         # Set-Content -Path $Log -Value $Date
         # Add-Content -Path $Log -Value $CommandLine
      } Catch {
        $ErrorMsg = "Error: Cannot create log file."
        ReportException $CommandLine $Error $_
        Exit
     } # Try
   } # if ($Log)

   # Import data from the specified source file.
   # If anything goes wrong with this, write the error to the console and exit.
   Try {
      [xml]$RWExportData = Get-Content -Path $Source
   } Catch {
        $ErrorMsg = "Error: Cannot read source file."
        ReportException $CommandLine $Error $_
   } # Try

   # Get the title from the specified output file.
   $Title = $RWExportData.Output.definition.details.name

   # Create and prime the HTML output file.
   # If anything goes wrong with this, write the error to the console and exit.
   Try {
      [System.IO.File]::WriteAllText($Destination,"<html>")
      [System.IO.File]::AppendAllText($Destination,"<head>")
      [System.IO.File]::AppendAllText($Destination,"<title>$Title</title>")
      [System.IO.File]::AppendAllText($Destination,'<link rel="stylesheet" type="text/css" href="main.css">')

      # Just in case this file gets posted on a public web site, tell googlebot not to index this page.
      [System.IO.File]::AppendAllText($Destination,'<meta name="googlebot" content="noindex">')

      # Continue priming the HTML output file.
      [System.IO.File]::AppendAllText($Destination,"</head>")
      [System.IO.File]::AppendAllText($Destination,"<body>")
      [System.IO.File]::AppendAllText($Destination,$TitleCSS.Replace("*",$Title))
   } Catch {
        $ErrorMsg = "Error: Cannot write destination file."
        ReportException $CommandLine $Error $_
   } # Try

   # Get the main content from the output file.
   $Contents = $RWExportData.output.contents

   # Get the topic list, and sort it according to the specified method.
   Switch ($Sort) {
      1 {$TopicList = $Contents.topic | Sort-Object public_name}
      2 {$TopicList = $Contents.topic | Sort-Object prefix,public_name}
      3 {$TopicList = $Contents.topic | Sort-Object category_name,public_name}
      4 {$TopicList = $Contents.topic | Sort-Object category_name,prefix,public_name}
      default {$TopicList = $Contents.topic}
   }


   $Parent = "/"
   foreach ($Topic in $TopicList) {
      ParseTopic $Topic $Destination $Sort $Prefix $Suffix $Details $Indent $SeparateSnippets $InlineStats $SimpleImageScale $SmartImageScale $Parent $TitleCSS $TopicCSS $TopicDetailsCSS $SectionCSS $SnippetCSS $Indcrement $Log
   } # foreach ($Topic in $Contents.topic)

   # Close out the HTML file

   [System.IO.File]::AppendAllText($Destination,"</body>")
   [System.IO.File]::AppendAllText($Destination,"</html>")
   # Add-Content -Path $Destination -Value "</body>"
   # Add-Content -Path $Destination -Value "</html>"

# } Main