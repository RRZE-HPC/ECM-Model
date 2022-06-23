
{% assign param-names = site.data.model_params.in-core.names %}
{% assign param-keys = site.data.model_params.in-core.keys %}

<div markdown="1" id="in-core-table">

### In-core metrics

<div style="display: block; overflow-x: auto; white-space: nowrap;">
<table>
<thead>
  <tr class="header">
  {% for param in param-names %}
   <th> {{ param }} </th>
  {% endfor %}
  </tr>
</thead>
<tbody>
{% for modelname in modelnames %}
  {% assign data = site.data.models[modelname] %}
    {% if data.name %}
    {% tablerow key in param-keys %}
      {%- if data[key] contains " " -%}
          {{- data[key] -}}
      {% else %}
         <code>{{- data[key] -}}</code>
      {% endif %}
    {% endtablerow %}
    {% endif %}
{% endfor %}
</tbody>
</table>
</div>

</div>
