{% assign param-names = site.data.model_params.in-core.names %}
{% assign param-keys = site.data.model_params.in-core.keys %}

{% assign names = "" %}
{% for model in site.data.models %}
  {% assign names = model[1].name | append: "|" | prepend: names %}
{% endfor %}
{% assign names = names | split: "|" | uniq | sort %}

{% assign modelnames = "" %}
{% for name in names %}
  {% for model in site.data.models %}
    {% if name == model[1].name %}
      {% assign modelnames = model[0] | append: "|" | prepend: modelnames %}
    {% endif %}
  {% endfor %}
{% endfor %}
{% assign modelnames = modelnames | split: "|" %}

<div markdown="1" id="in-core-table">

# Processors 
<p>
<i class='fa fa-microchip'></i>
</p>

{% for modelname in modelnames %}
{% assign data = site.data.models[modelname] %}
- [{{- data.name -}}](/{{-modelname-}}/)
{% endfor %}
