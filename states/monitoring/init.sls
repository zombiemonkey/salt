{% for key, value in salt['state.show_top']().iteritems() %}
echo "{{ key }}":
  cmd.run
{% endfor %}
