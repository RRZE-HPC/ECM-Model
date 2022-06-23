
{% assign mparam-names = site.data.model_params.memory.names %}
{% assign mparam-keys = site.data.model_params.memory.keys %}

<div markdown="1" id="memory-table">

### Memory metrics

<div style="display: block; overflow-x: auto; white-space: nowrap;">
<table>
<thead>
  <tr class="header">
  {% for param in mparam-names %}
   <th> {{ param }} </th>
  {% endfor %}
  </tr>
</thead>
<tbody>
{% for modelname in modelnames %}
  {% assign data = site.data.models[modelname] %}
    {% if data.name %}
    {% tablerow key in mparam-keys %}
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
