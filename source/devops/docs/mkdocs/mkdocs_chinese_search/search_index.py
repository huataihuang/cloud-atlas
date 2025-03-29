import jieba # Chinese word separation module

class SearchIndex:

    # The above remains unchanged

    def _add_entry(self, title, text, loc):
        """
        A simple wrapper to add an entry and ensure the contents
        is UTF8 encoded.
        """
        text = text.replace('\u3000', ' ') # Replace Chinese full space
        text = text.replace('\u00a0', ' ')
        text = re.sub(r'[ \t\n\r\f\v]+', ' ', text.strip())

        # Split text into words
        text_seg_list = jieba.cut_for_search(text)  # Search engine mode, with higher recall rate
        text = " ".join(text_seg_list) # join words with space

        # Split title into words
        title_seg_list = jieba.cut(title, cut_all=False) # Precise mode, more readable
        title = " ".join(title_seg_list) # join words with space

        self._entries.append({
            'title': title,
            'text': str(text.encode('utf-8'), encoding='utf-8'),
            'location': loc
        })

    # The following remains unchanged
