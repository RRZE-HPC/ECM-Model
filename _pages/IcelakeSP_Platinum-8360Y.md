---
permalink: /IcelakeSP_Platinum-8360Y/
title: "Intel Icelake SP Platinum 8360Y (ICX)"
---

# {{page.title}}
<!-- MANUAL ADJUSTMENT PER PROCESSOR -->
{% assign names = "Intel Icelake SP Platinum 8360Y (ICX)" %}
{% assign modelnames = "IcelakeSP_Platinum-8360Y" %}
{% assign datapath = "/icx36_results/" %}
<!-- =============================== -->
{% assign lineplots = "" %}
{% assign boxplots = "" %}

{% for fi in site.static_files %}
  {% if fi.path contains datapath %}
    {% if fi.path contains "plots" %}
      {% assign lineplots = fi.path | append: "|" | prepend: lineplots %}
    {% else %}
      {% assign boxplots = fi.path | append: "|" | prepend: boxplots %}
    {% endif %}
  {% endif %}
{% endfor %}
{% assign lineplots = lineplots | split: "|" | uniq | sort %}
{% assign boxplots = boxplots | split: "|" | uniq | sort %}


{% include single-in-core.md %}

&nbsp;

{% include single-memory.md %}

&nbsp;

<div markdown="1" class="section-block-full">
  <div markdown="1" class="section-block-half">
## ECM Line graphs
{% for plot in lineplots %}
  {% assign kernelname = plot | split: "/" %}
  {% assign kernelname = kernelname[-1] | split: ".pdf" %}
### {{ kernelname }}
  <embed width="600px" height="600px" src="{{ plot }}#view=FitV" type="application/pdf" id="{{ kernelname }}">
{% endfor %}
  </div>
  <div markdown="1" class="section-block-half">
## ECM Box plots
{% for plot in boxplots %}
  {% assign kernelname = plot | split: "/" %}
  {% assign kernelname = kernelname[-1] | split: ".png" %}
### {{ kernelname }}
  <img width="600px" height="600px" src="{{ plot }}" id="{{ kernelname }}_box">
{% endfor %}
  </div>
</div>

