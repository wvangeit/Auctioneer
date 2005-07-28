<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="*">
		<xsl:value-of select="."/>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:value-of select="."/>
 	</xsl:template>

	<xsl:template match="/">
		      <HTML>
		         <HEAD>
        		    <TITLE>
		               <xsl:value-of select="devdoc/@title"/>
		            </TITLE>
		         </HEAD>
		          <BODY STYLE="font:9pt Verdana">
		            <xsl:for-each select="devdoc">
		               <H1>
		                  <xsl:value-of select="@title"/>
		               </H1>
		            </xsl:for-each>

		        <hr/>
		        <H2>Table of Contents</H2>

		        <xsl:apply-templates select="devdoc/file" mode="toc"/>

		        <hr/>
		        <xsl:apply-templates/>
		        </BODY>
		      </HTML>
	</xsl:template>

  <!-- Table of Contents templates -->
  <xsl:template match="file|function" mode="toc">
    <DIV STYLE="margin-left:1em">
      <a>
      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:apply-templates select="." mode="sectionNum"/><!--<xsl:eval>sectionNum(this)</xsl:eval>-->
      </xsl:attribute>
      <xsl:apply-templates select="." mode="sectionNum"/><!--<xsl:eval>sectionNum(this)</xsl:eval>-->
      <xsl:text> </xsl:text>
      <xsl:value-of select="@name"/>
      </a>
      <xsl:apply-templates select="function" mode="toc"/>
    </DIV>
  </xsl:template>

   <xsl:template match="devdoc">
     <xsl:apply-templates />
   </xsl:template>
   <xsl:template match="file">
      <h2>
          <a> 
            <xsl:attribute name="name">
              <xsl:apply-templates select="." mode="sectionNum"/><!--<xsl:eval>sectionNum(this)</xsl:eval>-->
            </xsl:attribute>
            <xsl:apply-templates select="." mode="sectionNum"/><!--<xsl:eval>sectionNum(this)</xsl:eval>-->
            <xsl:text> </xsl:text>
            <xsl:value-of select="@name"/>
          </a>
      </h2>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="function">
      <h3>
          <a> 
            <xsl:attribute name="name">
              <xsl:apply-templates select="." mode="sectionNum"/><!--<xsl:eval>sectionNum(this)</xsl:eval>-->
            </xsl:attribute>
            <xsl:apply-templates select="." mode="sectionNum"/><!--<xsl:eval>sectionNum(this)</xsl:eval>-->
            <xsl:text> </xsl:text>
            <xsl:if test="@locale='true'">
            	<span style="color:#00cc00">
        	<xsl:value-of select="@name"/>
        	<xsl:text> (locale)</xsl:text>
	        </span>
            </xsl:if>
            <xsl:if test="@locale='false'">
            	<span style="color:#ff0000">
        	<xsl:value-of select="@name"/>
        	<xsl:text> (global)</xsl:text>
	        </span>
            </xsl:if>
          </a>
      </h3>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="parameter">
   	<xsl:text>Parameter: </xsl:text>
   	<xsl:value-of select="@name" />
   	<br />
   	<xsl:value-of select="." />
   	<p />
   </xsl:template>
   <xsl:template match="return">
   	<xsl:text>Returnvalue: </xsl:text>
   	<xsl:value-of select="@type" />
   	<br />
   	<xsl:value-of select="." />
   	<p />
   </xsl:template>
   <xsl:template match="description">
   	<xsl:text>Description: </xsl:text>
   	<br />
   	<xsl:value-of select="." />
   	<p />
   </xsl:template>

<!-- Section numbering -->

<xsl:template match="*" mode="sectionNum">
  <xsl:apply-templates select="parent::*" mode="sectionNum"/>
</xsl:template>
<xsl:template match="file|function" mode="sectionNum">
  <xsl:apply-templates select="parent::*" mode="sectionNum"/>
  <xsl:number/>
  <xsl:text>.</xsl:text>
</xsl:template>

</xsl:stylesheet>
