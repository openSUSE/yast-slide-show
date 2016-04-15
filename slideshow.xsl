<?xml version='1.0'?>
<xsl:stylesheet
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
   xmlns:exsl="http://exslt.org/common"
   extension-element-prefixes="exsl">

<xsl:output method="html" encoding = "UTF-8"/>
<xsl:param name="out.dir" select="'outdir'"/>

<xsl:template match="section/section">
  <xsl:variable name="chunk.name"
                select="@label"/>
  <xsl:variable name="imgdir"
                select="concat ($out.dir, '/', $chunk.name, '.rtf')"/>

  <xsl:choose>
    <xsl:when test="element-available('exsl:document')">
     <exsl:document href = "{$imgdir}"
                    omit-xml-declaration = "yes"
                    method = "xml"
                    encoding = "UTF-8"
                    media-type = "print"
                    indent = "yes">
       <table>
         <xsl:attribute name="cellspacing">
           <xsl:value-of select="'10'"/>
         </xsl:attribute>
         <xsl:attribute name="cellpadding">
           <xsl:value-of select="'5'"/>
         </xsl:attribute>

        <tr>
        <td>
         <xsl:attribute name="valign">
           <xsl:value-of select="'top'"/>
         </xsl:attribute>
         <!-- <xsl:text><![CDATA[<img src="&imagedir;/]]></xsl:text> -->
         <img>
         <xsl:attribute name="src">
         <xsl:value-of select="concat('%imagedir%/', $chunk.name, '.png')"/>
</xsl:attribute>

         <xsl:attribute name="width">
           <xsl:value-of select="'150'"/>
         </xsl:attribute>
         <xsl:attribute name="valign">
           <xsl:value-of select="'top'"/>
         </xsl:attribute>
<!--        <xsl:text><![CDATA[>]]></xsl:text> -->
</img>
        </td>
        <td>
          <xsl:apply-templates />
        </td>
       </tr>
      </table>
     </exsl:document>
    </xsl:when>
    <xsl:otherwise>
     <xsl:message>exsl missing</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="section/section/title">
 <h2>
  <xsl:apply-templates />
 </h2>
</xsl:template>

<xsl:template match="para">
 <p>
  <xsl:apply-templates />
 </p>
</xsl:template>

<xsl:template match="itemizedlist">
 <ul><xsl:apply-templates /></ul>
</xsl:template>
<xsl:template match="orderedlist">
 <ol><xsl:apply-templates /></ol>
</xsl:template>
<xsl:template match="listitem">
 <li><xsl:apply-templates /></li>
</xsl:template>
<xsl:template match="emphasis">
 <em><xsl:apply-templates /></em>
</xsl:template>

</xsl:stylesheet>

<!--
 <xsl:message>
  <xsl:value-of select="$chunk.name" />
</xsl:message>
-->
