for f in *.csv; do
    printf '\'' "${f%.csv}" "%s\\'" >> file_lists.txt
done
